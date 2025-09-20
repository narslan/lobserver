defmodule Lobserver.Metrics.MemoryCollector do
  use GenServer
  require Logger

  @interval 1_000

  # API
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: :memory_collector)
  end

  # Callbacks
  @impl true
  def init(_) do
    schedule()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:collect, state) do
    now = System.system_time(:second)
    # MB
    mem = :erlang.memory(:total) / 1_000_000
    WhiteRabbit.insert(:white_rabbit, :memory, now, mem)
    schedule()
    {:noreply, state}
  end

  defp schedule(), do: Process.send_after(self(), :collect, @interval)
end
