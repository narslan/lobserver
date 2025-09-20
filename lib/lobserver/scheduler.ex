defmodule Lobserver.Metrics.SchedulerCollector do
  use GenServer
  require Logger

  @interval 1_000

  # API
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: :scheduler_collector)
  end

  # Callbacks
  @impl true
  def init(_) do
    # :erlang.system_flag(:scheduler_wall_time, true)
    last = :erlang.statistics(:scheduler_wall_time)
    schedule()
    {:ok, %{last: last}}
  end

  @impl true
  def handle_info(:collect, %{last: last} = state) do
    now = :erlang.statistics(:scheduler_wall_time)

    {active_delta, total_delta} =
      Enum.zip(last, now)
      |> Enum.reduce({0, 0}, fn {{_id, a1, t1}, {_id2, a2, t2}}, {a, t} ->
        {a + (a2 - a1), t + (t2 - t1)}
      end)

    utilization = if total_delta == 0, do: 0.0, else: active_delta / total_delta

    WhiteRabbit.insert(:white_rabbit, :scheduler_util, System.system_time(:second), utilization)

    schedule()
    {:noreply, %{state | last: now}}
  end

  defp schedule(), do: Process.send_after(self(), :collect, @interval)
end
