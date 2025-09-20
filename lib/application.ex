defmodule Lobserver.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :erlang.system_flag(:scheduler_wall_time, true)

    children = [
      {Registry, keys: :unique, name: Lobserver.Registry},
      {WhiteRabbit.Coordinator, name: :white_rabbit},
      Lobserver.Metrics.ReductionsCollector,
      Lobserver.Metrics.MemoryCollector,
      Lobserver.Metrics.SchedulerCollector,
      {Bandit, plug: Lobserver.Router, port: 8000}
    ]

    opts = [strategy: :one_for_one, name: Lobserver.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
