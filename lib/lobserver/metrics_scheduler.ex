defmodule Lobserver.Metrics.Scheduler do
  use GenServer

  # alle 1 Sekunden
  @interval 1_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, pid} = WhiteRabbit.Coordinator.start_link()
    schedule_tick()
    {:ok, %{white_rabbit_pid: pid}}
  end

  @impl true
  def handle_info(:collect, %{white_rabbit_pid: pid} = state) do
    Lobserver.Metrics.Collector.collect(pid)
    schedule_tick()
    {:noreply, state}
  end

  defp schedule_tick() do
    Process.send_after(self(), :collect, @interval)
  end

  def get_pid(), do: GenServer.call(__MODULE__, :get_pid)

  @impl true
  def handle_call(:get_pid, _from, state) do
    {:reply, state.white_rabbit_pid, state}
  end
end
