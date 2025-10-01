defmodule Lobserver.Metrics.ReductionsCollector do
  use GenServer

  @interval 1_000

  # API
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: :reductions_collector)
  end

  # Callbacks
  @impl true
  def init(_) do
    schedule()
    {:ok, %{last: :erlang.statistics(:reductions)}}
  end

  @impl true
  def handle_info(:collect, %{last: {last_reds, last_gc}} = state) do
    {now_reds, now_gc} = :erlang.statistics(:reductions)

    delta = {now_reds - last_reds, now_gc - last_gc}

    WhiteRabbit.insert(:white_rabbit, :reductions, System.system_time(:second), delta)
    schedule()
    {:noreply, %{state | last: {now_reds, now_gc}}}
  end

  defp schedule(), do: Process.send_after(self(), :collect, @interval)
end
