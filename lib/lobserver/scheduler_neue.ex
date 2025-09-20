defmodule Lobserver.Metrics.SchedulerCollectorNeue do
  use GenServer

  # alle 5 Sekunden
  @interval 5_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
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

    # Hier kannst du utilization ins Log schreiben, Metriken exportieren etc.
    IO.inspect(utilization, label: "Scheduler utilization")

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
  def tuple_to_map({type, id, utilization, percent_chars}) do
    %{
      type: type,
      id: id,
      # Float 0.0–1.0
      utilization: utilization,
      # Float 0.0–100.0
      percent: percent_from_charlist(percent_chars)
    }
  end

  # Ganze Ergebnisliste umwandeln
  def utilization_to_maps(utilization_result) when is_list(utilization_result) do
    Enum.map(utilization_result, &tuple_to_map/1)
  end
end
