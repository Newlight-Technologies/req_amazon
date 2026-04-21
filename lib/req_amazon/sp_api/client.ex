defmodule ReqAmazon.SpApi.Client do
  @moduledoc """
  Convenience builder for configured SP-API Req clients.
  """

  @plugin_option_keys [:credentials, :sandbox]

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
