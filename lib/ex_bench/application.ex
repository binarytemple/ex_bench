defmodule ExBench.Application do
  @moduledoc false

  use Application
  @appname :ex_bench
  require Logger
  @delay 1000

  def poolboy_config do
    [
      {:name, {:local, :worker}},
      {:worker_module, ExBench.Worker},
      {:size, Application.get_env(@appname, :workers)},
      {:max_overflow, Application.get_env(@appname, :overflow)}
    ]
  end

  def signaller_config() do
    conf = %{
      bench_fun: Application.get_env(@appname, :bench_fun),
      producer: Application.get_env(@appname, :producer),
      producer_argument: Application.get_env(@appname, :producer_argument),
      concurrency: Application.get_env(@appname, :concurrency),
      delay: @delay
    }

    Map.to_list(conf)
    |> Enum.each(fn
      {k, nil} -> raise("#{inspect(@appname)} #{inspect(k)} cannot be nil, check your config")
      _ -> :ok
    end)

    conf
  end

  def bench_fun_config() do
    Application.get_env(@appname, :bench_fun)
  end

  def start_default() do
    start([], [])
  end

  @default_filename "#{List.to_string(:code.priv_dir(:ex_bench))}/example.consult"

  @spec start_demo(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def start_demo(args \\ [bench_fun: fn x -> IO.inspect(x) end, filename: @default_filename])
      when is_list(args) do
    conf = [
      workers: 10,
      overflow: 2,
      concurrency: 3,
      bench_fun: args[:bench_fun],
      producer: ExBench.FileProducer,
      producer_argument: %{filename: args[:filename]}
    ]

    conf |> Enum.each(&Application.put_env(@appname, elem(&1, 0), elem(&1, 1)))
    start(nil, Mix.env())
  end

  def start(type, env_type) do
    Logger.debug("#{__MODULE__} start(#{inspect([type, env_type])})")

    children = [
      :poolboy.child_spec(:worker, poolboy_config(), bench_fun_config()),
      {ExBench.Signaler, signaller_config()}
    ]

    # ugly - has side effect..
    children =
      case env_type do
        :dev ->
          ExBench.Metrics.CommandInstrumenter.setup()
          ExBench.Dev.Metrics.PlugExporter.setup()
          Prometheus.Registry.register_collector(:prometheus_process_collector)

          cbs = [
            # Plug.Cowboy.child_spec(
            #   scheme: :http,
            #   plug: ExBench.Dev.Pipeline,
            #   options: [port: 4001]
            # )
          ]

          children ++ cbs

        _ ->
          children
      end

    opts = [strategy: :one_for_one, name: ExBench.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def stop() do
    Logger.debug("#{__MODULE__} terminating")
    Supervisor.stop(ExBench.Supervisor)
  end
end
