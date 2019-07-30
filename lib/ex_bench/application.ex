defmodule ExBench.Application do
  use Application
  require Logger

  def start(_type, _args) do
    [:gen_stage, :prometheus_ex, :prometheus]
    |> Enum.each(&Application.ensure_all_started(&1))

    ExBench.Metrics.CommandInstrumenter.setup()

    children = [
      {ExBench.DynamicSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: ExBench.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def stop() do
    stop(nil)
  end

  def stop(_state) do
    Logger.debug("#{__MODULE__} terminating")
    Supervisor.stop(ExBench.Supervisor)
  end
end
