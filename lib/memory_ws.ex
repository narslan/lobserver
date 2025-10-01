defmodule Lobserver.WebSocket.Memory do
  require Logger

  def init(_) do
    state = %{}
    {:ok, state}
  end

  def handle_in({"ping", [opcode: :text]}, state) do
    # Antworte auf Client-Pings
    {:push, {:text, "pong"}, state}
  end

  def handle_in({raw, [opcode: :text]}, state) do
    case JSON.decode(raw) do
      {:ok, %{"action" => "get_process_info", "pid" => pid}} ->
        Logger.debug("Retreives infos PID #{inspect(pid)}")

        # z. B. deine eigene Funktion:
        info = Lobserver.Process.info(pid)

        result = %{action: "result_process_info", data: info}
        {:push, {:text, JSON.encode!(result)}, state}

      {:ok, %{"action" => "get_memory"}} ->
        m = :erlang.memory() |> Enum.map(fn {k, v} -> %{key: k, value: humanize(v)} end)
        result = %{action: "result_memory", data: m}
        {:push, {:text, JSON.encode!(result)}, state}

      {:ok, %{"action" => "get_processes"}} ->
        m =
          Lobserver.Process.list()
          |> Enum.reject(fn %{init: init} -> String.contains?(init, "ThousandIsland") end)

        result = %{action: "result_process", data: m}
        {:push, {:text, JSON.encode!(result)}, state}

      _ ->
        Logger.warning("unkown message: #{raw}")
        {:ok, state}
    end
  end

  def terminate(_reason, state) do
    Logger.warning("remote closed")
    {:noreply, state}
  end

  defp humanize(bytes) do
    Sizeable.filesize(bytes)
  end
end
