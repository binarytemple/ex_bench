defmodule ExBench.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_bench,
      version: "0.2.7",
      elixir: "~> 1.6 or ~> 1.7 or ~> 1.8 or ~> 1.9",
      start_permanent: Mix.env() == :prod,
      package: package(),
      application: application(),
      description: description(),
      deps: deps()
    ]
  end

  def application() do
    case Keyword.get(Mix.Project.config(), :app) do
      :ex_bench ->
        application(Mix.env())

      _ ->
        dependent_application()
    end
  end

  def dependent_application() do
    [
      # extra_applications: [:logger,  :telemetry ],
      extra_applications: [:logger]
    ]
  end

  def application(:test) do
    [
      extra_applications: [:logger]
    ]
  end

  def application(:dev) do
    [
      # extra_applications: [:prometheus, :cowboy, :logger,  :telemetry, :telemetry_metrics_prometheus],
      extra_applications: [:prometheus, :cowboy, :logger],
      mod: {ExBench.Application, [[], []]}
    ]
  end

  def application(:prod) do
    [
      # extra_applications: [:prometheus, :cowboy, :logger, :telemetry, :telemetry_metrics_prometheus],
      extra_applications: [:prometheus, :cowboy, :logger],
      mod: {ExBench.Application, [[], []]}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:prometheus_ex, "~> 3.0", runtime: false},
      {:prometheus_plugs, "~> 1.1.5", runtime: false},
      {:prometheus_process_collector, "~> 1.4", runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:plug_cowboy, "~> 2.1"},
      # {:telemetry_metrics_prometheus, "~> 0.2", runtime: false},
      {:gen_stage, "~> 0.14"},
      {:poolboy, "~> 1.5"}
      # {:telemetry, "~> 0.4"}
    ]
  end

  defp package() do
    [
      files:
      ~w( lib/ex_bench/metrics lib/ex_bench/file_producer lib/ex_bench/worker.ex lib/ex_bench/dynamic_supervisor.ex lib/ex_bench/signaller.ex lib/ex_bench/application.ex lib/ex_bench/file_producer.ex .formatter.exs mix.exs priv README.md LICENSE), 
      homepage_url: "https://github.com/bryanhuntesl/ex_bench",
      licenses: ["Apache 2"],
      links: %{"GitHub" => "https://github.com/bryanhuntesl/ex_bench"},
      source_url: "https://github.com//bryanhuntesl/ex_bench"
    ]
  end

  defp description() do
    "An application you can use for benchmarking, read terms from a file (or other Producer) and execute them against an anonymous function of your choice"
  end
end
