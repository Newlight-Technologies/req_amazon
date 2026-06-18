defmodule ReqAmazon.SpApi.Token.Lwa do
  @moduledoc false

  # Default token provider: exchanges credentials with Amazon's Login with Amazon
  # endpoint for both refresh-token and grantless (client-credentials) grants.

  @behaviour ReqAmazon.SpApi.Token.Provider

  alias ReqAmazon.SpApi.Error

  @impl true
  def fetch(grant, credentials, request_options \\ [], owner \\ self()) do
    maybe_allow_req_test(request_options, owner)

    options =
      request_options
      |> Keyword.merge(form: form(grant, credentials))
      |> Keyword.put_new(:retry, :transient)

    case Req.post(ReqAmazon.SpApi.Config.token_url(), options) do
      {:ok,
       %Req.Response{
         status: status,
         body: %{"access_token" => access_token, "expires_in" => expires_in}
       }}
      when status in 200..299 ->
        case normalize_expires_in(expires_in) do
          {:ok, seconds} ->
            {:ok, access_token, DateTime.add(DateTime.utc_now(), seconds, :second)}

          :error ->
            {:error,
             Error.from_response(status, %{
               "errors" => [
                 %{
                   "code" => "InvalidTokenResponse",
                   "message" => "Amazon LWA token response included invalid expires_in"
                 }
               ]
             })}
        end

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, Error.from_response(status, body)}

      {:error, error} ->
        {:error, Error.wrap(error)}
    end
  end

  defp form({:refresh_token, refresh_token}, credentials) do
    [
      grant_type: "refresh_token",
      client_id: credentials.client_id,
      client_secret: credentials.client_secret,
      refresh_token: refresh_token
    ]
  end

  defp form({:client_credentials, scope}, credentials) do
    [
      grant_type: "client_credentials",
      client_id: credentials.client_id,
      client_secret: credentials.client_secret,
      scope: scope
    ]
  end

  defp maybe_allow_req_test(request_options, owner) do
    case Keyword.get(request_options, :plug) do
      {Req.Test, name} when is_pid(owner) ->
        _ = Req.Test.allow(name, owner, self())
        :ok

      _ ->
        :ok
    end
  end

  defp normalize_expires_in(expires_in) when is_integer(expires_in), do: {:ok, expires_in}

  defp normalize_expires_in(expires_in) when is_binary(expires_in) do
    case Integer.parse(expires_in) do
      {seconds, ""} -> {:ok, seconds}
      _invalid -> :error
    end
  end

  defp normalize_expires_in(_expires_in), do: :error
end
