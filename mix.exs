defmodule ExBench.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_bench,
      version: "0.2.3",
      elixir: "~> 1.6 or ~> 1.7 or ~> 1.8 or ~> 1.9",
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps()
    ]
  end

  def application() do
    application(Mix.env())
  end

  # Run "mix help compile.app" to learn about applications.
  # dont start the application automatically :
  def application(:test) do
    [
      extra_applications: extra_applications()
    ]
  end

  def application(:dev) do
    IO.puts("application:dev")

    [
      extra_applications: [:prometheus, :cowboy] ++ extra_applications(),
      mod: {ExBench.Application, Mix.env()}
    ]
  end

  def application(:prod) do
    [
      extra_applications: extra_applications()
    ]
  end

  def extra_applications() do
    [:logger, :telemetry]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:prometheus_ex, "~> 3.0", only: :dev, runtime: false},
      # {:prometheus_ex, "~> 3.0", only: :dev, runtime: false},
      {:prometheus_plugs, "~> 1.1.5"},
      {:prometheus_process_collector, "~> 1.4", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:gen_stage, "~> 0.14"},
      {:poolboy, "~> 1.5"},
      {:telemetry_metrics_prometheus, "~> 0.2"}
    ]
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs priv README.md LICENSE),
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
