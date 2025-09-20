defmodule Lobserver.MetricCollector do
  defmacro __using__(opts) do
    metric = Keyword.fetch!(opts, :metric)
    interval = Keyword.get(opts, :interval, 1_000)

    quote do
      use GenServer
      @metric unquote(metric)
      @interval unquote(interval)

      ## --- Public API
      def start_link(_opts) do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
      end

      ## --- GenServer Callbacks
      def init(state) do
        schedule()
        {:ok, %{last: nil}}
      end

      def handle_info(:collect, %{last: nil} = state) do
        # Erstmalige Messung → nur speichern, noch nicht auswerten
        raw = collect_raw()
        schedule()
        {:noreply, %{state | last: raw}}
      end

      def handle_info(:collect, %{last: last} = state) do
        raw = collect_raw()
        delta = compute_delta(last, raw)
        ts = System.system_time(:second)
        insert(@metric, ts, delta)
        schedule()
        {:noreply, %{state | last: raw}}
      end

      ## --- Helpers
      defp insert(metric, ts, val) do
        case Registry.lookup(Lobserver.Registry, :white_rabbit) do
          [{pid, _}] -> WhiteRabbit.insert(pid, metric, ts, val)
          [] -> :noop
        end
      end

      defp schedule, do: Process.send_after(self(), :collect, @interval)

      ## --- To be implemented by collectors
      @callback collect_raw() :: term()
      @callback compute_delta(term(), term()) :: number()
    end
  end
end
