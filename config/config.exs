use Mix.Config

config :poc_event_timer,
  workers: 5,
  overflow: 2,
  concurrency: 5,
  bench_fun: fn x -> IO.inspect(x) end,
  producer: PocEventTimer.Producer,
  producer_args: %{filename: "./test/consult.me"}

#     import_config "#{Mix.env()}.exs"
