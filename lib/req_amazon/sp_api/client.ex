defmodule ReqAmazon.SpApi.Client do
  @moduledoc """
  Convenience builder for configured SP-API Req clients.

  Use `new/1` when you want a ready-to-call request with the SP-API plugin
  attached.

  Configuration options resolve into a `ReqAmazon.SpApi.Config`:

  - `:region` - `:na` | `:eu` | `:fe`; sets the endpoint and AWS signing region.
  - `:endpoint`, `:aws_region`, `:user_agent` - explicit overrides.
  - `:sign?` - enable AWS SigV4 signing (default `false`).
  - `:sandbox` - target Amazon's sandbox host.

  Plugin options: `:credentials`, `:access_token`, `:grantless_scope`. Any other
  option (e.g. `:plug`, `:receive_timeout`, `:base_url`) is passed to `Req`.
  """

  alias ReqAmazon.SpApi.Config

  @config_option_keys [:region, :endpoint, :aws_region, :user_agent, :sign?, :sandbox]
  @plugin_option_keys [:access_token, :credentials, :grantless_scope]

  @doc """
  Builds a configured Req client for Amazon SP-API requests.
  """
  @spec new(keyword()) :: Req.Request.t()
  def new(overrides \\ []) when is_list(overrides) do
    {config_options, rest} = Keyword.split(overrides, @config_option_keys)
    {plugin_options, request_options} = Keyword.split(rest, @plugin_option_keys)

    config = Config.new(config_options)

    Req.new(base_url: config.endpoint, retry: :transient)
    |> Req.merge(request_options)
    |> ReqAmazon.SpApi.attach([{:config, config} | plugin_options])
  end
end
