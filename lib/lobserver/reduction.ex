defmodule Lobserver.Metrics.ReductionsCollector do
  use GenServer
  require Logger

  @interval 1_000

  # API
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: :reductions_collector)
  end

  # Callbacks
  @impl true
  def init(_) do
    schedule()
    last = :erlang.statistics(:reductions)
    {:ok, %{last: last}}
  end

  @impl true
  def handle_info(:collect, %{last: last} = state) do
    now = :erlang.statistics(:reductions)
    delta = {elem(now, 0) - elem(last, 0), elem(now, 1) - elem(last, 1)}
    WhiteRabbit.insert(:white_rabbit, :reductions, System.system_time(:second), delta)
    schedule()
    {:noreply, %{state | last: now}}
  end

  defp schedule(), do: Process.send_after(self(), :collect, @interval)
end
