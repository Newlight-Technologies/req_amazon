defmodule ReqAmazon.SpApi.Client do
  @moduledoc """
  Convenience builder for configured SP-API Req clients.

  Use `new/1` when you want a ready-to-call request with the SP-API plugin
  attached. Pass normal Req options such as `:base_url`, and pass plugin options
  such as `:credentials`, `:access_token`, and `:sandbox`.
  """

  @plugin_option_keys [:access_token, :credentials, :grantless_scope, :sandbox]

  @doc """
  Builds a configured Req client for Amazon SP-API requests.
  """
  @spec new(keyword()) :: Req.Request.t()
  def new(overrides \\ []) when is_list(overrides) do
    {plugin_options, request_options} = Keyword.split(overrides, @plugin_option_keys)

    Req.new(base_url: ReqAmazon.SpApi.endpoint(), retry: :transient)
    |> Req.merge(request_options)
    |> ReqAmazon.SpApi.attach(plugin_options)
  end
end
