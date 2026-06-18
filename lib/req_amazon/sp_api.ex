defmodule ReqAmazon.SpApi do
  @moduledoc """
  Req plugin for the Amazon Selling Partner API.

  Handles authentication and request/response processing for both
  Seller and Vendor SP-API endpoints:

  - Login with Amazon access-token injection via `x-amz-access-token`
  - AWS SigV4 request signing
  - SP-API sandbox host rewriting
  - Required `user-agent` header injection
  - SP-API error unwrapping for non-2xx responses

  ## Usage

      req = ReqAmazon.SpApi.Client.new()
      ReqAmazon.SpApi.Orders.list_orders(req, marketplace_ids: ["ATVPDKIKX0DER"], created_after: "2024-01-01")

  Or attach to an existing Req request:

      req = Req.new(base_url: "https://sellingpartnerapi-na.amazon.com")
      |> ReqAmazon.SpApi.attach(credentials: %{...})

  If your application manages LWA refresh itself, pass an access token per request:

      req =
        Req.new(base_url: "https://sellingpartnerapi-eu.amazon.com")
        |> ReqAmazon.SpApi.attach(
          credentials: %{
            aws_access_key_id: "...",
            aws_secret_access_key: "...",
            aws_region: "eu-west-1"
          },
          access_token: token
        )
  """

  alias ReqAmazon.SpApi.{Auth, Error, Headers, Response}

  @default_endpoint "https://sellingpartnerapi-na.amazon.com"
  @default_marketplace_id "ATVPDKIKX0DER"
  @default_region "us-east-1"
  @default_token_url "https://api.amazon.com/auth/o2/token"
  @plugin_options [:access_token, :credentials, :sandbox]
  @forward_request_option_keys [
    :adapter,
    :connect_options,
    :finch,
    :finch_private,
    :inet6,
    :max_retries,
    :plug,
    :pool_max_idle_time,
    :pool_timeout,
    :receive_timeout,
    :retry,
    :retry_delay,
    :retry_log_level,
    :unix_socket
  ]
  @required_signing_credential_keys [:aws_access_key_id, :aws_secret_access_key]
  @required_lwa_credential_keys [:client_id, :client_secret, :refresh_token]
  @credential_keys @required_signing_credential_keys ++
                     @required_lwa_credential_keys ++ [:aws_region]

  @type credentials :: %{
          required(:aws_access_key_id) => String.t(),
          required(:aws_secret_access_key) => String.t(),
          optional(:client_id) => String.t(),
          optional(:client_secret) => String.t(),
          optional(:refresh_token) => String.t(),
          optional(:aws_region) => String.t()
        }

  @doc """
  Attaches the Amazon SP-API request and response steps to a Req request.

  Supported plugin options:

  - `:credentials` - SP-API credentials for LWA and SigV4 signing.
  - `:access_token` - caller-managed LWA access token. When present, the plugin
    injects the `x-amz-access-token` header and skips the internal token refresh.
  - `:sandbox` - rewrites the request host to Amazon's sandbox host.
  """
  @spec attach(Req.Request.t(), keyword()) :: Req.Request.t()
  def attach(%Req.Request{} = request, options \\ []) do
    request
    |> Req.Request.register_options(@plugin_options)
    |> Req.Request.merge_options(options)
    |> ensure_credentials()
    |> ensure_aws_sigv4()
    |> Req.Request.prepend_request_steps(
      sp_api_sandbox_url: &sp_api_sandbox_url/1,
      sp_api_lwa_token: &sp_api_lwa_token/1,
      sp_api_user_agent: &sp_api_user_agent/1
    )
    |> Req.Request.append_response_steps(sp_api_unwrap_errors: &sp_api_unwrap_errors/1)
  end

  @doc false
  @spec request(Req.Request.t(), atom(), String.t(), keyword()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  def request(%Req.Request{} = request, method, path, options \\ [])
      when is_atom(method) and is_binary(path) and is_list(options) do
    case Req.request(request, Keyword.merge([method: method, url: path], options)) do
      {:ok, %Req.Response{} = response} ->
        {:ok, Response.from_req(response)}

      {:error, error} ->
        {:error, Error.wrap(error)}
    end
  end

  @doc false
  @spec credentials(nil | map() | keyword()) :: credentials()
  def credentials(nil), do: credentials()

  def credentials(credentials) when is_list(credentials) do
    credentials
    |> Enum.into(%{})
    |> credentials()
  end

  def credentials(%{} = credentials) do
    credentials(credentials, require_lwa?: true)
  end

  def credentials(other) do
    raise ArgumentError,
          "expected SP-API credentials as a map or keyword list, got: #{inspect(other)}"
  end

  @doc false
  @spec credentials(nil | map() | keyword(), keyword()) :: credentials()
  def credentials(nil, opts) do
    :req_amazon
    |> Application.fetch_env!(:sp_api_credentials)
    |> credentials(opts)
  end

  def credentials(credentials, opts) when is_list(credentials) do
    credentials
    |> Enum.into(%{})
    |> credentials(opts)
  end

  def credentials(%{} = credentials, opts) do
    required_keys =
      @required_signing_credential_keys ++
        if Keyword.get(opts, :require_lwa?, true), do: @required_lwa_credential_keys, else: []

    normalized =
      Enum.reduce(@credential_keys, %{}, fn key, acc ->
        case credential_value(credentials, key) do
          nil -> acc
          value -> Map.put(acc, key, value)
        end
      end)

    case Enum.reject(required_keys, &Map.has_key?(normalized, &1)) do
      [] ->
        Map.put_new(normalized, :aws_region, @default_region)

      missing ->
        raise ArgumentError,
              "missing required SP-API credentials: #{Enum.map_join(missing, ", ", &inspect/1)}"
    end
  end

  @doc false
  @spec credentials() :: credentials()
  def credentials do
    credentials(nil, require_lwa?: true)
  end

  @doc false
  @spec endpoint() :: String.t()
  def endpoint do
    Application.get_env(:req_amazon, :sp_api_endpoint, @default_endpoint)
  end

  @doc false
  @spec marketplace_id() :: String.t()
  def marketplace_id do
    Application.get_env(:req_amazon, :sp_api_marketplace_id, @default_marketplace_id)
  end

  @doc false
  @spec token_url() :: String.t()
  def token_url do
    Application.get_env(:req_amazon, :sp_api_token_url, @default_token_url)
  end

  @doc false
  @spec user_agent() :: String.t()
  def user_agent do
    Application.get_env(:req_amazon, :sp_api_user_agent, default_user_agent())
  end

  @doc false
  @spec aws_sigv4(credentials()) :: keyword()
  def aws_sigv4(credentials) do
    credentials = credentials(credentials, require_lwa?: false)

    [
      access_key_id: credentials.aws_access_key_id,
      secret_access_key: credentials.aws_secret_access_key,
      region: credentials.aws_region,
      service: "execute-api"
    ]
  end

  defp ensure_credentials(request) do
    require_lwa? = not access_token_provided?(request)

    case Map.get(request.options, :credentials) do
      nil ->
        Req.Request.merge_new_options(request,
          credentials: credentials(nil, require_lwa?: require_lwa?)
        )

      provided ->
        Req.Request.merge_options(
          request,
          credentials: credentials(provided, require_lwa?: require_lwa?)
        )
    end
  end

  defp ensure_aws_sigv4(request) do
    Req.Request.merge_new_options(request, aws_sigv4: aws_sigv4(request.options[:credentials]))
  end

  defp sp_api_sandbox_url(request) do
    if request.options[:sandbox] do
      cond do
        request.url.scheme ->
          %{request | url: sandbox_uri(request.url)}

        base_url = request.options[:base_url] ->
          Req.Request.merge_options(request, base_url: sandbox_base_url(base_url))

        true ->
          request
      end
    else
      request
    end
  end

  defp sp_api_lwa_token(request) do
    case Req.Request.get_header(request, "x-amz-access-token") do
      [] ->
        case request.options[:access_token] do
          token when is_binary(token) and byte_size(token) > 0 ->
            Req.Request.put_header(request, "x-amz-access-token", token)

          _ ->
            credentials = request.options[:credentials]
            request_options = forwarded_request_options(request)

            case Auth.fetch_access_token(credentials, request_options, self()) do
              {:ok, token} ->
                Req.Request.put_header(request, "x-amz-access-token", token)

              {:error, error} ->
                Req.Request.halt(request, error)
            end
        end

      _existing ->
        request
    end
  end

  defp sp_api_user_agent(request) do
    Req.Request.put_new_header(request, "user-agent", user_agent())
  end

  defp sp_api_unwrap_errors({request, %Req.Response{status: status} = response})
       when status in 200..299 do
    {request, response}
  end

  defp sp_api_unwrap_errors({request, %Req.Response{status: status, body: body} = response}) do
    {request,
     Error.from_response(status, body,
       request_id: Headers.request_id(response),
       retry_after: Headers.retry_after(response),
       rate_limit: Headers.rate_limit(response)
     )}
  end

  defp sandbox_base_url(%URI{} = base_url), do: sandbox_uri(base_url)

  defp sandbox_base_url(base_url) when is_binary(base_url),
    do: base_url |> URI.parse() |> sandbox_uri()

  defp sandbox_base_url(base_url), do: base_url

  defp sandbox_uri(%URI{host: nil} = uri), do: uri

  defp sandbox_uri(%URI{host: "sandbox." <> _} = uri), do: uri

  defp sandbox_uri(%URI{host: host} = uri) do
    %{uri | host: "sandbox." <> host}
  end

  defp forwarded_request_options(request) do
    request.options
    |> Map.take(@forward_request_option_keys)
    |> Enum.to_list()
  end

  defp access_token_provided?(request) do
    match?([_ | _], Req.Request.get_header(request, "x-amz-access-token")) or
      match?(token when is_binary(token) and byte_size(token) > 0, request.options[:access_token])
  end

  defp credential_value(credentials, key) do
    case Map.fetch(credentials, key) do
      {:ok, value} -> value
      :error -> Map.get(credentials, Atom.to_string(key))
    end
  end

  defp default_user_agent do
    version =
      :req_amazon
      |> Application.spec(:vsn)
      |> to_string()

    "req_amazon/#{version} (Elixir/#{System.version()})"
  end
end
