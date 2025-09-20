defmodule Lobserver.Metrics.Collector do
  use GenServer

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_init_args) do
    {:ok, pid} = WhiteRabbit.Coordinator.start_link()
    schedule_tick()
    {:ok, %{white_rabbit_pid: pid, last: %{}}}
  end

  @impl true
  def handle_call(:get_pid, _from, state) do
    {:reply, state.white_rabbit_pid, state}
  end

  @impl true
  def handle_info(:collect, %{white_rabbit_pid: pid, last: last} = state) do
    now = System.system_time(:second)
    process_count = :erlang.system_info(:process_count)
    {reductions, _} = :erlang.statistics(:reductions)

    {rate, new_last} =
      case last[:reductions] do
        nil ->
          {0.0, {now, reductions}}

        {prev_ts, prev_val} ->
          dt = now - prev_ts
          dv = reductions - prev_val
          r = if dt > 0 and dv >= 0, do: dv / dt, else: 0.0
          {r, {now, reductions}}
      end

    WhiteRabbit.insert(pid, "runtime.process_count", now, process_count)
    WhiteRabbit.insert(pid, "runtime.reductions", now, reductions)
    WhiteRabbit.insert(pid, "runtime.reductions_per_sec", now, rate)

    schedule_tick()
    {:noreply, %{state | last: Map.put(last, :reductions, new_last)}}
  end

  defp schedule_tick() do
    Process.send_after(self(), :collect, 1_000)
  end

  def get_pid() do
    GenServer.call(__MODULE__, :get_pid)
  end
end

# defmodule Lobserver.Metrics.Collector do
#   @moduledoc """
#   Sammelt Runtime- und Systemmetriken und speichert sie in WhiteRabbit.
#   """

#   require Logger

#   def collect(pid) do
#     now = System.system_time(:second)

#     # --- Runtime Metriken (BEAM selbst) ---
#     process_count = :erlang.system_info(:process_count)
#     {reductions, _} = :erlang.statistics(:reductions)
#     {runtime_ms, _} = :erlang.statistics(:runtime)
#     {wall_ms, _} = :erlang.statistics(:wall_clock)
#     memory = :erlang.memory(:total)

#     WhiteRabbit.insert(pid, "runtime.process_count", now, process_count)
#     WhiteRabbit.insert(pid, "runtime.reductions", now, reductions)
#     WhiteRabbit.insert(pid, "runtime.runtime_ms", now, runtime_ms)
#     WhiteRabbit.insert(pid, "runtime.wall_ms", now, wall_ms)
#     WhiteRabbit.insert(pid, "runtime.memory_bytes", now, memory)

#     # --- Systemmetriken (OS-Level über :os_mon) ---
#     cpu_util =
#       case :cpu_sup.util() do
#         :undefined -> nil
#         val -> val
#       end

#     if cpu_util do
#       WhiteRabbit.insert(pid, "system.cpu_util", now, cpu_util)
#     end

#     memsup_data =
#       case :memsup.get_system_memory_data() do
#         :undefined -> []
#         data -> data
#       end

#     Enum.each(memsup_data, fn {k, v} ->
#       metric_name = "system.memory." <> Atom.to_string(k)
#       WhiteRabbit.insert(pid, metric_name, now, v)
#     end)

#     :ok
#   end
# end
