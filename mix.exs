defmodule ExBench.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_bench,
      version: "0.3.1",
      elixir: "~> 1.6 or ~> 1.7 or ~> 1.8 or ~> 1.9",
      start_permanent: false,
      package: package(),
      application: application(),
      description: description(),
      deps: deps()
    ]
  end

  def application() do
    application(Mix.env())
  end

  def application(:test) do
    [
      extra_applications: [:logger]
    ]
  end

  def application(:dev) do
    [
      extra_applications: extra_applications(),
      mod: {ExBench.Application, [[], []]}
    ]
  end

  def application(:prod) do
    [
      extra_applications: extra_applications(),
      mod: {ExBench.Application, [[], []]}
    ]
  end

  def extra_applications() do
    [:prometheus, :logger]
  end

  defp deps do
    [
      {:prometheus_ex, "~> 3.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false, optional: true},
      {:recon, "~> 2.5.0"},
      {:gen_stage, "~> 0.14"},
      {:poolboy, "~> 1.5"}
    ]
  end

  defp package() do
    [
      files: ~w( lib src .formatter.exs mix.exs priv README.md LICENSE),
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
