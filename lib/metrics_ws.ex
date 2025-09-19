defmodule Lobserver.WebSocket.Metrics do
  require Logger

  def init(_) do
    Logger.debug("start metrics")
    # wir holen den pid später über Scheduler
    {:ok, %{}}
  end

  def handle_in({message, [opcode: :text]}, state) do
    case JSON.decode(message) do
      {:ok, %{"action" => "process_metrics"}} ->
        pid = Lobserver.Metrics.Scheduler.get_pid()
        result = get_from_whiterabbit(pid, "runtime.process_count")
        {:push, {:text, JSON.encode!(result)}, state}

      {:ok, %{"action" => "cpu_metrics"}} ->
        pid = Lobserver.Metrics.Scheduler.get_pid()
        result = get_from_whiterabbit(pid, "system.cpu_util")
        {:push, {:text, JSON.encode!(result)}, state}

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

    {xs, ys} = Enum.unzip(Enum.map(data, fn {_metric, ts, val} -> {ts, val} end))

    %{
      action: metric <> "_ok",
      data: [xs, ys]
    }
  end
end
