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

  def dev_signaller_config() do
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

  def run(args \\ [bench_fun: fn x -> IO.inspect(x) end, filename: default_filename()])
      when is_list(args) do
    [:telemetry, :gen_stage, :poolboy]
    |> Enum.each(&Application.ensure_all_started(&1))

    # IO.puts("RUN ARGS #{inspect(args)}")

    conf = %{
      workers: 10,
      overflow: 2,
      concurrency: 3,
      bench_fun: args[:bench_fun],
      producer: ExBench.FileProducer,
      producer_argument: %{filename: args[:filename]},
      delay: @delay
    }
    # conf[:bench_fun].("HELLO WORLD")
    ExBench.DynamicSupervisor.start_child(generate_poolboy_spec(conf[:bench_fun]))
    ExBench.DynamicSupervisor.start_child({ExBench.Signaler, conf})
  end

  def generate_poolboy_spec(
        bench_fun,
        config \\ [
          name: {:local, :worker},
          worker_module: ExBench.Worker,
          size: 10,
          max_overflow: 10
        ]
      ) do
    spec = %{
      id: :poolboy,
      start:
        {:poolboy, :start_link,
         [
           config,
           bench_fun
         ]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
    IO.inspect(spec)
  end

  def start(_type, _args) do
    # IO.puts("Logger not yet started")

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
    children_base = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: ExBench.Dev.Pipeline,
        options: [port: 4000, transport_options: [num_acceptors: 5, max_connections: 5]]
      )
    ]

    children =
      case env do
        :prod ->
          children_base ++ [{ExBench.DynamicSupervisor, []}]

        :dev ->
          children_base ++
            [
              {ExBench.DynamicSupervisor,
               [
                 generate_poolboy_spec(bench_fun_config(), poolboy_config()),
                 {ExBench.Signaler, dev_signaller_config()}
               ]}
            ]
      end

    opts = [strategy: :one_for_one, name: ExBench.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_as_dependency() do

    children = [
      :poolboy.child_spec(:worker, poolboy_config(), bench_fun_config()),
      {ExBench.DynamicSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: ExBench.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def stop() do
    Logger.debug("#{__MODULE__} terminating")
    Supervisor.stop(ExBench.Supervisor)
  end
end
