defmodule Lobserver.Metrics.SchedulerCollector do
  use GenServer

  @interval 1_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def init(_) do
    # erste Messung holen
    schedulers = :erlang.statistics(:scheduler_wall_time)
    state = %{last: schedulers}
    schedule()
    {:ok, state}
  end

  def handle_info(:collect, %{last: last} = state) do
    now = :erlang.statistics(:scheduler_wall_time)

    # Delta berechnen
    utilization =
      calc_utilization(last, now)
      |> Float.round(3)

    ts = System.system_time(:second)

    # In WhiteRabbit speichern
    WhiteRabbit.insert(:white_rabbit, "scheduler_util", ts, utilization)

    schedule()
    {:noreply, %{state | last: now}}
  end

  defp schedule, do: Process.send_after(self(), :collect, @interval)

  defp calc_utilization(last, now) do
    {active_delta, total_delta} =
      Enum.zip(last, now)
      |> Enum.reduce({0, 0}, fn {{_id, active1, total1}, {_id, active2, total2}}, {a, t} ->
        {a + (active2 - active1), t + (total2 - total1)}
      end)

    if total_delta == 0, do: 0.0, else: active_delta / total_delta
  end
end
