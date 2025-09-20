defmodule Lobserver.WebSocket.Metrics do
  require Logger

  def init(_) do
    Logger.debug("start metrics")
    # wir holen den pid später über Scheduler
    {:ok, %{}}
  end

  def handle_in({message, [opcode: :text]}, state) do
    case JSON.decode(message) do
      {:ok, %{"action" => "process_count"}} ->
        pid = Lobserver.Metrics.Collector.get_pid()

        {:push, {:text, JSON.encode!(get_from_whiterabbit(pid, "runtime.process_count"))}, state}

      {:ok, %{"action" => "reduction_metrics"}} ->
        pid = Lobserver.Metrics.Collector.get_pid()

        {:push, {:text, JSON.encode!(get_from_whiterabbit(pid, "runtime.reductions_per_sec"))},
         state}

      {:ok, %{"action" => "scheduler_metrics"}} ->
        data = get_scheduler_metrics()
        {:push, {:text, JSON.encode!(data)}, state}

      {:ok, %{"action" => other}} ->
        Logger.warning("Unhandled action: #{other}")
        {:ok, state}

      _ ->
        Logger.error("Invalid JSON: #{message}")
        {:ok, state}
    end
  end

  defp get_from_whiterabbit(pid, metric) do
    now = System.system_time(:second)
    data = WhiteRabbit.range(pid, metric, now - 60, now)

    # {xs, ys} = Enum.unzip(Enum.map(data, fn {_metric, ts, val} -> {ts, val} end))
    {xs, ys} = Enum.unzip(data)

    %{
      action: metric <> "_ok",
      data: [xs, ys]
    }
  end

  defp get_scheduler_metrics() do
    now = System.system_time(:second)
    data = WhiteRabbit.range(:white_rabbit, "scheduler_util", now - 60, now)
    {xs, ys} = Enum.unzip(data)
    %{action: "scheduler_metrics_ok", data: [xs, ys]}
  end
end
