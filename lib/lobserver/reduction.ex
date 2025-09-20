defmodule Lobserver.Metrics.ReductionsCollector do
  use Lobserver.MetricCollector, metric: :reductions, interval: 2_000

  # Rohdaten: Anzahl der Reduktionen
  def collect_raw() do
    :erlang.statistics(:reductions)
  end

  # Delta: Differenz zwischen letzter und aktueller Messung
  def compute_delta({r1_last, r2_last}, {r1_now, r2_now}) do
    {r1_now - r1_last, r2_now - r2_last}
  end
end
