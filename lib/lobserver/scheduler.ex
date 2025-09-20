defmodule Lobserver.Metrics.SchedulerCollector do
  use GenServer

  # alle 5 Sekunden
  @interval 1_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: :scheduler_collector)
  end

  def init(state) do
    :erlang.system_flag(:scheduler_wall_time, true)
    schedule_tick()
    {:ok, state}
  end

  def handle_info(:tick, state) do
    sample1 = :scheduler.get_sample_all()
    # Messintervall innerhalb der Periode
    :timer.sleep(1000)
    sample2 = :scheduler.get_sample_all()

    utilization = :scheduler.utilization(sample1, sample2)

    WhiteRabbit.insert(
      :white_rabbit,
      :scheduler_util,
      System.system_time(:second),
      utilization_to_value(utilization)
    )

    # IO.inspect(utilization, label: "Scheduler utilization")

    schedule_tick()
    {:noreply, state}
  end

  def terminate(_, _) do
    :erlang.system_flag(:scheduler_wall_time, false)
    :ok
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @interval)
  end

  # Einzelne Charlist wie '0.0%' in Float umwandeln
  def percent_from_charlist(charlist) when is_list(charlist) do
    charlist
    |> to_string()
    |> String.trim_trailing("%")
    |> String.to_float()
  end

  # Ein einzelnes Utilization-Tuple umwandeln
  def tuple_to_value({_, _, percent_chars}) do
    percent_from_charlist(percent_chars)
  end

  # Ganze Ergebnisliste umwandeln
  def utilization_to_value(utilization_result) when is_list(utilization_result) do
    Enum.filter(utilization_result, fn t -> elem(t, 0) == :weighted end)
    |> Enum.map(&tuple_to_value/1)
  end
end
