defmodule ExBench.Metrics.CommandInstrumenter do
  use Prometheus.Metric

  def setup() do
    Counter.declare(
      name: :ex_bench_worker,
      help: "Command Count",
      labels: [:command]
    )

    # events = [
    #   [:ex_bench, :worker]
    # ]

    # :telemetry.attach_many("ex_bench-commands", events, &handle_event/4, nil)
  end

  def handle_event([:ex_bench, :worker], _count, _metadata = %{command: command}, _config) do
    Counter.inc(name: :ex_bench_worker, labels: [command])
  end

def counter_inc( %{command: command} ) do
    Counter.inc(name: :ex_bench_worker, labels: [command])
  end


end
