defmodule Lobserver.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Lobserver.Registry},
      {Bandit, plug: Lobserver.Router, port: 8000}
    ]

    opts = [strategy: :one_for_one, name: Lobserver.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
