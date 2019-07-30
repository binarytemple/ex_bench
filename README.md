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

You will invoke ExBench.run - with no arguments - you can verify that the supervision system is working correctly, 
the default test run will be executed. Stop the run with `ExBench.stop`.

Or, to actually have it do something useful, initialize `%ExBench.Args{}` with custom arguments, and pass it to `ExBench.run`.

Example (Elixir) :

```elixir
iex(12)> args = %ExBench.Args{bench_fun: fn(x) -> IO.puts("foo: #{inspect(x)}") end} 
%ExBench.Args{
  bench_fun: #Function<6.99386804/1 in :erl_eval.expr/5>,
  concurrency: 3,
  delay: 1000,
  overflow: 2,
  producer: ExBench.FileProducer,
  producer_argument: %{
    filename: "/code/bryanhuntesl/ex_bench/_build/dev/lib/ex_bench/priv/example.consult"
  },
  workers: 10
}

ExBench.run(args)

```

Erlang :

```erlang
'Elixir.ExBench':run([ {  bench_fun, fun(X) -> io:format("I got the arguments ~w~n",[X]) end }, {filename, "/tmp/example.consult"}]).
```

## Stopping an ExBench run

Elixir :

```elixir
ExBench.stop()
```

Erlang :

```erlang
'Elixir.ExBench':stop()
```

## Application design / Supervision structure

![Supervision hierarchy](./doc/exbench_supervision_tree.png)

## Recording a trace ...

Capture a single invocation of `:io.format("foo",[])`

Erlang example :

```
'Elixir.ExBench.Capturer':capture("/tmp/foo.txt" , [ {trace_pattern, {io, format, 2}}, {count, 1}]).
```

Elixir example : 

```
ExBench.Capturer.capture("/tmp/foo.txt" , [ trace_pattern: {:io, :format, 2}, count: 1])
```


Erlang interface - Elixir example 

```
:ex_bench.run(10,10,5,fn(x) -> IO.inspect(x) end, ExBench.FileProducer, %{filename: "/tmp/example.consult"},1000)
```

Erlang interface - Erlang example 

```
ex_bench:run(10,10,5,fun(X) -> io:format("~w~n",[X]) end, 'Elixir.ExBench.FileProducer', %{filename => "/tmp/example.consult"},1000)
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
