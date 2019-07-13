use Mix.Config

config :logger,
  level: :debug

config :ex_bench,
  workers: 10,
  overflow: 2,
  concurrency: 5,
  bench_fun: fn x -> IO.inspect(x) end,
  producer: ExBench.FileProducer,
  producer_argument: %{filename: "./test/consult.me"}
