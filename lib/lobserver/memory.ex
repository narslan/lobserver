defmodule Lobserver.Metrics.MemoryCollector do
  use Lobserver.MetricCollector, metric: :memory, interval: 2_000

  # Rohdaten in Bytes aus der VM
  def collect_raw() do
    :erlang.memory(:total)
  end

  # Umrechnung in MB + Delta optional
  def compute_delta(_last, now_bytes) do
    bytes_to_mb(now_bytes)
  end

  defp bytes_to_mb(bytes) do
    # 1024 * 1024 = MB
    Float.round(bytes / 1_048_576, 2)
  end
end
