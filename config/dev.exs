use Mix.Config

config :logger,
  level: :debug

# ,
# handle_otp_reports: true,
# handle_sasl_reports: true

config :ex_bench,
  workers: 10,
  overflow: 2,
  concurrency: 3,
  bench_fun: fn x -> IO.inspect(x) end,
  producer: ExBench.FileProducer,
  producer_argument: %{filename: "priv/example.consult"}
