defmodule Lobserver.WebSocket.Metrics do
  require Logger

  def init(_) do
    Logger.debug("start metrics ")
    {:ok, pid} = WhiteRabbit.Coordinator.start_link()

    state = %{
      white_rabbit_pid: pid
    }

    {:ok, state}
  end

  def handle_in(
        {message, [opcode: :text]},
        %{white_rabbit_pid: pid} = state
      ) do
    case JSON.decode(message) do
      {:ok, %{"action" => "process_metrics"}} ->
        result = get_process_metrics(pid)
        Logger.debug("got result")
        {:push, {:text, JSON.encode!(result)}, state}

      {:ok, %{"action" => other}} ->
        Logger.warning("Unhandled action: #{other}")
        {:ok, state}

      _ ->
        Logger.error("Invalid JSON: #{message}")
        {:ok, state}
    end
  end

  def terminate(reason, state) do
    Logger.warning("remote closed with #{inspect(reason)}")

    {:noreply, state}
  end

  defp get_process_metrics(pid) do
    now = System.system_time(:second)
    process_count = :erlang.system_info(:process_count)

    # Speichern
    WhiteRabbit.insert(pid, "process", now, process_count)

    # Abrufen für den Client
    data = WhiteRabbit.range(pid, "process", now - 60, now)

    {xs, ys} =
      Enum.unzip(data)

    %{
      action: "process_metrics_ok",
      data: [xs, ys]
    }
  end
end
