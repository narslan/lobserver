defmodule Lobserver.WebSocket.Memory do
  require Logger

  def init(_) do
    state = %{}
    {:ok, state}
  end

  def handle_in({"pong", [opcode: :text]}, state) do
    {:push, {:text, "ping"}, state}
  end

  def handle_in({"ping", [opcode: :text]}, state) do
    {:push, {:text, "pong"}, state}
  end

  def handle_in(
        {"{\"action\":\"onMemory\"}", [opcode: :text]},
        state
      ) do
    Logger.debug("get memory")
    m = :erlang.memory() |> Enum.map(fn {k, v} -> %{key: k, value: humanize(v)} end)
    result = %{action: "result_memory", data: m}
    {:push, {:text, JSON.encode!(result)}, state}
  end

  def handle_in(
        {"{\"action\":\"onProcess\"}", [opcode: :text]},
        state
      ) do
    Logger.debug("get process")

    m =
      Lobserver.Process.list()
      |> Enum.reject(fn %{init: init} -> String.contains?(init, "ThousandIsland") end)

    result = %{action: "result_process", data: m}
    {:push, {:text, JSON.encode!(result)}, state}
  end

  def terminate(reason, state) do
    Logger.warning("remote closed with #{reason}")

    {:noreply, state}
  end

  defp humanize(bytes) do
    Sizeable.filesize(bytes)
  end
end
