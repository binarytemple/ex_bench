# ExBench

[![CI status](https://travis-ci.org/bryanhuntesl/ex_bench.svg?branch=master)](https://travis-ci.org/bryanhuntesl/ex_bench) / [Hexdocs](https://hexdocs.pm/ex_bench/)

An application for white box load testing

## Recording a trace

Capture a single invocation of `:io.format("foo",[])`

### Recording a trace Elixir example

```elixir
ExBench.Capturer.capture("/tmp/foo.txt" , [ trace_pattern: {:io, :format, 2}, count: 1])
```

### Recording a trace Erlang example

```erlang
'Elixir.ExBench.Capturer':capture("/tmp/foo.txt" , [ {trace_pattern, {io, format, 2}}, {count, 1}]).
```

## Invocation (Elixir)

You will invoke ExBench.run - with no arguments - you can verify that the supervision system is working correctly,
the default test run will be executed. Stop the run with `ExBench.stop`.

Or, to actually have it do something useful, initialize `%ExBench.Args{}` with custom arguments, and pass it to `ExBench.run`.

### Invocation example - Elixir

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

### Invocation example - Erlang API

#### Erlang interface - Elixir example

```elixir
:ex_bench.run(10,10,5,fn(x) -> IO.inspect(x) end, ExBench.FileProducer, %{filename: "/tmp/example.consult"},1000)
```

#### Erlang interface - Erlang example

```erlang
ex_bench:run(10,10,5,fun(X) -> io:format("~w~n",[X]) end, 'Elixir.ExBench.FileProducer', #{filename => <<"/tmp/example.consult">>},1000)
```

## Stopping an ExBench run (Elixir)

```elixir
ExBench.stop()
```

## Stopping an ExBench run (Erlang)

```erlang
'Elixir.ExBench':stop()
```

## Application design / Supervision structure

![Supervision hierarchy](./doc/exbench_supervision_tree.png)

## Supported Elixir/OTP versions

See [travis build](https://travis-ci.org/bryanhuntesl/ex_bench) for definitive, up-to-date, test matrix.

As of July 2019 - these are the tested versions:

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
