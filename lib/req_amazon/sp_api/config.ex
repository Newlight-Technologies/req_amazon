defmodule ReqAmazon.SpApi.Config do
  @moduledoc """
  Resolved, explicit configuration for an SP-API client.

  Bundles the region-derived endpoint, the AWS signing region, the user agent,
  and the `sign?`/`sandbox?` toggles into one value so callers pass a single
  thing instead of relying on scattered application config.

  ## Regions

  Pass `:region` and the endpoint and AWS signing region are resolved from
  Amazon's published table:

  | region | endpoint                                   | aws_region |
  |--------|--------------------------------------------|------------|
  | `:na`  | `https://sellingpartnerapi-na.amazon.com`  | us-east-1  |
  | `:eu`  | `https://sellingpartnerapi-eu.amazon.com`  | eu-west-1  |
  | `:fe`  | `https://sellingpartnerapi-fe.amazon.com`  | us-west-2  |

  Without a `:region`, the endpoint falls back to the `:sp_api_endpoint`
  application config (default North America) and the signing region to
  `us-east-1`. An explicit `:endpoint`/`:aws_region` always wins.

  ## Signing

  `sign?` defaults to `false`. Amazon no longer requires AWS SigV4 on SP-API
  calls — the LWA access token is sufficient — so signing (and the AWS
  credentials it needs) is opt-in.
  """

  @default_aws_region "us-east-1"
  @default_endpoint "https://sellingpartnerapi-na.amazon.com"
  @default_token_url "https://api.amazon.com/auth/o2/token"

  @regions %{
    na: %{endpoint: "https://sellingpartnerapi-na.amazon.com", aws_region: "us-east-1"},
    eu: %{endpoint: "https://sellingpartnerapi-eu.amazon.com", aws_region: "eu-west-1"},
    fe: %{endpoint: "https://sellingpartnerapi-fe.amazon.com", aws_region: "us-west-2"}
  }

  defstruct [:region, :endpoint, :aws_region, :user_agent, sign?: false, sandbox?: false]

  @type region :: :na | :eu | :fe

  @type t :: %__MODULE__{
          region: region() | nil,
          endpoint: String.t(),
          aws_region: String.t(),
          user_agent: String.t(),
          sign?: boolean(),
          sandbox?: boolean()
        }

  @doc "The published region table (region => endpoint + AWS signing region)."
  @spec regions() :: %{region() => %{endpoint: String.t(), aws_region: String.t()}}
  def regions, do: @regions

  @doc "Looks up a single region's endpoint/aws_region, or `nil` if unknown."
  @spec region(region()) :: %{endpoint: String.t(), aws_region: String.t()} | nil
  def region(region), do: Map.get(@regions, region)

  @doc """
  Builds a config from options.

  Options: `:region`, `:endpoint`, `:aws_region`, `:user_agent`, `:sign?`,
  `:sandbox`. Anything omitted falls back to the region table, then application
  config, then library defaults.
  """
  @spec new(keyword()) :: t()
  def new(opts \\ []) when is_list(opts) do
    info = region_info(Keyword.get(opts, :region))

    %__MODULE__{
      region: Keyword.get(opts, :region),
      endpoint: Keyword.get(opts, :endpoint) || (info && info.endpoint) || default_endpoint(),
      aws_region:
        Keyword.get(opts, :aws_region) || (info && info.aws_region) || @default_aws_region,
      user_agent: Keyword.get(opts, :user_agent) || default_user_agent(),
      sign?: Keyword.get(opts, :sign?, false),
      sandbox?: Keyword.get(opts, :sandbox, false)
    }
  end

  @doc "The LWA token endpoint (`:sp_api_token_url` config, or Amazon's default)."
  @spec token_url() :: String.t()
  def token_url do
    Application.get_env(:req_amazon, :sp_api_token_url, @default_token_url)
  end

  @doc false
  @spec resolve(t() | keyword() | nil) :: t()
  def resolve(%__MODULE__{} = config), do: config
  def resolve(nil), do: new()
  def resolve(opts) when is_list(opts), do: new(opts)

  defp region_info(nil), do: nil

  defp region_info(region) do
    region(region) ||
      raise ArgumentError,
            "unknown SP-API region #{inspect(region)}; expected one of #{inspect(Map.keys(@regions))}"
  end

  defp default_endpoint do
    Application.get_env(:req_amazon, :sp_api_endpoint, @default_endpoint)
  end

  defp default_user_agent do
    Application.get_env(:req_amazon, :sp_api_user_agent, library_user_agent())
  end

  defp library_user_agent do
    version = :req_amazon |> Application.spec(:vsn) |> to_string()
    "req_amazon/#{version} (Elixir/#{System.version()})"
  end
end
