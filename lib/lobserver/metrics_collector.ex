defmodule Lobserver.Metrics.Collector do
  @moduledoc """
  Sammelt Runtime- und Systemmetriken und speichert sie in WhiteRabbit.
  """

  require Logger

  def collect(pid) do
    now = System.system_time(:second)

    # --- Runtime Metriken (BEAM selbst) ---
    process_count = :erlang.system_info(:process_count)
    {reductions, _} = :erlang.statistics(:reductions)
    {runtime_ms, _} = :erlang.statistics(:runtime)
    {wall_ms, _} = :erlang.statistics(:wall_clock)
    memory = :erlang.memory(:total)

    WhiteRabbit.insert(pid, "runtime.process_count", now, process_count)
    WhiteRabbit.insert(pid, "runtime.reductions", now, reductions)
    WhiteRabbit.insert(pid, "runtime.runtime_ms", now, runtime_ms)
    WhiteRabbit.insert(pid, "runtime.wall_ms", now, wall_ms)
    WhiteRabbit.insert(pid, "runtime.memory_bytes", now, memory)

    # --- Systemmetriken (OS-Level über :os_mon) ---
    cpu_util =
      case :cpu_sup.util() do
        :undefined -> nil
        val -> val
      end

    if cpu_util do
      WhiteRabbit.insert(pid, "system.cpu_util", now, cpu_util)
    end

    memsup_data =
      case :memsup.get_system_memory_data() do
        :undefined -> []
        data -> data
      end

    Enum.each(memsup_data, fn {k, v} ->
      metric_name = "system.memory." <> Atom.to_string(k)
      WhiteRabbit.insert(pid, metric_name, now, v)
    end)

    :ok
  end
end
