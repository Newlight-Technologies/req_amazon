defmodule ReqAmazon.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ReqAmazon.SpApi.Token.Cache
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ReqAmazon.Supervisor)
  end
end
