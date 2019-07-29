# ExBench

[![CI status](https://travis-ci.org/bryanhuntesl/ex_bench.svg?branch=master)](https://travis-ci.org/bryanhuntesl/ex_bench) / [Hexdocs](https://hexdocs.pm/ex_bench/)

An application for white box load testing 

## Default configuration (dev running standalone)

[config/dev.exs](config/dev.exs)

```elixir 
config :ex_bench,
  workers: 10,
  overflow: 2,
  concurrency: 3,
  bench_fun: fn x -> IO.inspect(x) end,
  producer: ExBench.FileProducer,
  producer_argument: %{filename: "priv/example.consult"}
```

## Invocation (when using as a dependency) 

Typically you will leave the defaults as they currently are (workers, overflow, concurrency, producer).

You will invoke ExBench.run - with no arguments - you can verify that the supervision system is working correctly, 
the default test run will be executed.

Or, and this is what you'll want to do 99.9% of the time, invoke ExBench.run - passing as arguments, the function to run 
and the file to load arguments from. 

For example (Elixir) : 

```elixir
ExBench.run(bench_fun: fn x -> IO.puts("I got the arguments #{inspect(x)} end, filename: "/tmp/example.consult")
```

Erlang : 

```erlang
'Elixir.ExBench':run([ {  bench_fun, fun(X) -> io:format("I got the arguments ~w~n",[X]) end }, {filename, "/tmp/example.consult"}]).
```

## Application design / Supervision structure

![Supervision hierarchy](./doc/exbench_supervision_tree.png)

## Recording a trace ... 

Capture a single invocation of 

Erlang example :

```
'Elixir.ExBench.Capturer':capture("/tmp/foo.txt" , [ {trace_pattern, {io, format, 2}}, {count, 1}]).
```

Elixir example : 

```
ExBench.Capturer.capture("/tmp/foo.txt" , [ trace_pattern: {:io, :format, 2}, count: 1])
```


## Supported Elixir/OTP versions 

See [travis build](https://travis-ci.org/bryanhuntesl/ex_bench) for definitive, up-to-date, test matrix.

|Elixir|  OTP |
|------|------|
| 1.6  | 19   |
| 1.6  | 20.3 |
| 1.6  | 21   |
| 1.7  | 19   |
| 1.7  | 20.3 |
| 1.7  | 21   |
| 1.7  | 22   |
| 1.8.1| 20.3 |
| 1.8.1| 21   |
| 1.8.1| 22   |
| 1.9.0| 20.3 |
| 1.9.0| 21   |
| 1.9.0| 22   |
|------|------|


## Tricks

### Make a bigger input arguments file

```bash
for i in `seq 1 10000` ;  do echo "{test1,{\"$i\", <<7,166>>, #{},[],false, #{<<\"x\">> => <<\"y\">>}}}." ; done >> test/consult.me
```
