defmodule ExBench.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_bench,
      version: "0.2.0",
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
      extra_applications: extra_applications(),
      mod: {ExBench.Application, [[], []]}
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
      {:poolboy, "~> 1.5"},
      {:gen_stage, "~> 0.14"},
      {:telemetry_metrics_prometheus, "~> 0.2"}

      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp package() do
    [
      licenses: ["Apache 2"],
      links: %{"GitHub" => "https://github.com/bryanhuntesl/ex_bench"},
      source_url: "https://github.com//bryanhuntesl/ex_bench",
      homepage_url: "https://github.com/sescobb27/ex_bench",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE)
    ]
  end

  defp description() do
    "An application you can use for benchmarking, read terms from a file (or other Producer) and execute them against an anonymous function of your choice"
  end
end
