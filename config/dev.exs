use Mix.Config


config :logger,
  level: :debug

config :poc_event_timer,
  workers: 10,
  overflow: 2,
  concurrency: 5,
  bench_fun: fn x -> IO.inspect(x) end,
  producer: PocEventTimer.FileProducer,
  producer_argument: %{filename: "./test/consult.me"}
