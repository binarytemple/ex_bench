# ExBench

[![CI status](https://travis-ci.org/bryanhuntesl/ex_bench.svg?branch=master)](https://travis-ci.org/bryanhuntesl/ex_bench)

An application for white box load testing 

## Default configuration (dev running standalone)

```elixir
config :poc_event_timer,
  workers: 2,  #number of poolby worker processes
  overflow: 2, # temporarily allocate these if needed
  concurrency: 2, # how many instances of the task should be run in parallel
  bench_fun: fn x -> IO.inspect(x) end, # the function that you apply to each line of input
  producer: ExBench.FileProducer, # this produces the inputs (in this example, it reads them from the specified file)
  producer_argument: %{filename: "./test/consult.me"} # the argument applied to producer.init/1
```

### Runtime dependencies

* :ex_prometheus

### Startup behavior

The startup behavior of this application depends on whether you embed it as a dependency or run it as a standalone application, for example with `iex -S mix` or `MIX_ENV=prod iex -S mix` or `mix test`.

| Startup type        | Environment | Behavior                                                                                                                                                                                                                |
| ------------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| As a dependency     | any         | starts :logger - doesn't run the default task until you execute ExBench.Application.run                                                                                                                                 |
| Standalone          | :dev        | starts application, webserver, prometheus and prometheus export to :4000/metrics - starts running the default task                                                                                                      |
| Standalone          | :prod       | starts application, webserver, prometheus and prometheus export to :4000/metrics - doesn't run the default task until you execute [ExBench.Application.run](https://hexdocs.pm/ex_bench/ExBench.Application.html#run/1) |
| Standalone          | :test       | starts :logger, all scafolding is carried out in the tests/test helper

## Application design

![Supervision hierarchy](./doc/exbench_supervision_tree.png)

## Tricks

### Make a bigger input arguments file

```bash
for i in `seq 1 10000` ;  do echo "{test1,{\"$i\", <<7,166>>, #{},[],false, #{<<\"x\">> => <<\"y\">>}}}." ; done >> test/consult.me
```
