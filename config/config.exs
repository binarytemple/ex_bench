use Mix.Config

config :poc_event_timer,
  workers: 2,
  overflow: 2,
  concurrency: 2,
  bench_fun: fn x -> IO.inspect(x) end,
  producer: PocEventTimer.Producer,
  producer_argument: %{filename: "./test/consult.me"}

#     import_config "#{Mix.env()}.exs"
