

defmodule ExBench.Application do
  @moduledoc false

  use Application
  require Logger
  @delay 1000

  def is_dependency(), do: Keyword.get(Mix.Project.config(), :app) != :ex_bench
  def mix_env(), do: Mix.env()

  def poolboy_config do
    [
      {:name, {:local, :worker}},
      {:worker_module, ExBench.Worker},
      {:size, Application.get_env(:ex_bench, :workers)},
      {:max_overflow, Application.get_env(:ex_bench, :overflow)}
    ]
  end

  def signaller_config() do
    conf = %{
      bench_fun: Application.get_env(:ex_bench, :bench_fun),
      producer: Application.get_env(:ex_bench, :producer),
      producer_argument: Application.get_env(:ex_bench, :producer_argument),
      concurrency: Application.get_env(:ex_bench, :concurrency),
      delay: @delay
    }

    Map.to_list(conf)
    |> Enum.each(fn
      {k, nil} -> raise("#{inspect(:ex_bench)} #{inspect(k)} cannot be nil, check your config")
      _ -> :ok
    end)

    conf
  end

  def bench_fun_config() do
    Application.get_env(:ex_bench, :bench_fun)
  end

  defp default_filename(), do: "#{List.to_string(:code.priv_dir(:ex_bench))}/example.consult"

  @spec run(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def run(args \\ [bench_fun: fn x -> IO.inspect(x) end, filename: default_filename()])
      when is_list(args) do
    [:telemetry, :gen_stage, :poolboy, :telemetry_metrics_prometheus]
    |> Enum.each(&Application.ensure_all_started(&1))

    conf = %{
      workers: 10,
      overflow: 2,
      concurrency: 3,
      bench_fun: args[:bench_fun],
      producer: ExBench.FileProducer,
      producer_argument: %{filename: args[:filename]}
    }

    # conf |> Enum.each(&Application.put_env(:ex_bench, elem(&1, 0), elem(&1, 1)))

      ExBench.DynamicSupervisor.start_child( { ExBench.Signaler, [conf] })
  end

  def start(_type, _args) do
    :io.format("Logger not started", [])
    # Logger.error("#{__MODULE__} start(#{inspect([start_type, env_type])})")
    # Logger.error("#{__MODULE__} running as dependency == #{is_dependency()}")

    case is_dependency() do
      false ->
        start_as_standalone_app(mix_env())

      true ->
        start_as_dependency()
    end
  end

  def start_as_standalone_app(env) do
    Logger.warn("starting as standalone app, env: #{env}")
    ExBench.Metrics.CommandInstrumenter.setup()
    ExBench.Metrics.PlugExporter.setup()
    Prometheus.Registry.register_collector(:prometheus_process_collector)

    children_basic = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: ExBench.Dev.Pipeline,
        options: [port: 4000, transport_options: [num_acceptors: 5, max_connections: 5]]
      ),
      :poolboy.child_spec(:worker, poolboy_config(), bench_fun_config()),
      {ExBench.DynamicSupervisor , []},
    ]

    children =
      case env do
        :prod -> children_basic
        :dev -> children_basic
        # :dev -> children_basic ++ [{ExBench.Signaler, signaller_config()}]
      end

    opts = [strategy: :one_for_one, name: ExBench.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_as_dependency() do
    ExBench.Metrics.CommandInstrumenter.setup()
    ExBench.Metrics.PlugExporter.setup()
    Prometheus.Registry.register_collector(:prometheus_process_collector)

    children = [
      :poolboy.child_spec(:worker, poolboy_config(), bench_fun_config()),
      {ExBench.DynamicSupervisor , []}
    ]

    opts = [strategy: :one_for_one, name: ExBench.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def stop() do
    Logger.debug("#{__MODULE__} terminating")
    Supervisor.stop(ExBench.Supervisor)
  end
end
