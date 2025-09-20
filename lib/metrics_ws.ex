defmodule Lobserver.WebSocket.Metrics do
  require Logger

  def init(_) do
    Logger.debug("start metrics")
    # wir holen den pid später über Scheduler
    {:ok, %{}}
  end

  def handle_in({message, [opcode: :text]}, state) do
    case JSON.decode(message) do
      {:ok, %{"action" => "reductions_metrics"}} ->
        data = get_reductions_metrics()
        {:push, {:text, JSON.encode!(data)}, state}

      {:ok, %{"action" => "scheduler_metrics"}} ->
        data = get_scheduler_metrics()
        {:push, {:text, JSON.encode!(data)}, state}

      {:ok, %{"action" => "memory_metrics"}} ->
        data = get_memory_metrics()
        {:push, {:text, JSON.encode!(data)}, state}

      {:ok, %{"action" => other}} ->
        Logger.warning("Unhandled action: #{other}")
        {:ok, state}

      _ ->
        Logger.error("Invalid JSON: #{message}")
        {:ok, state}
    end
  end

  defp get_scheduler_metrics() do
    now = System.system_time(:second)
    data = WhiteRabbit.range(:white_rabbit, :scheduler_util, now - 60, now)
    {xs, ys} = Enum.unzip(data)
    %{action: "scheduler_ok", data: [xs, ys]}
  end

  defp get_reductions_metrics() do
    now = System.system_time(:second)
    data = WhiteRabbit.range(:white_rabbit, :reductions, now - 60, now)
    {xs, ys} = Enum.unzip(Enum.map(data, fn {x, {_y, z}} -> {x, z} end))
    %{action: "reductions_ok", data: [xs, ys]}
  end

  defp get_memory_metrics() do
    now = System.system_time(:second)
    data = WhiteRabbit.range(:white_rabbit, :memory, now - 60, now)
    {xs, ys} = Enum.unzip(data)
    %{action: "memory_ok", data: [xs, ys]}
  end
end
