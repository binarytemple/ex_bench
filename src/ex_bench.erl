-module(ex_bench).

-export([run/7]).

run(Workers, Overflow, Concurrency, Bench_fun, Producer,
    Producer_argument, Delay)
    when is_map(Producer_argument) ->
    M = #{workers => Workers, overflow => Overflow,
	  concurrency => Concurrency, bench_fun => Bench_fun,
	  producer => Producer,
	  producer_argument => Producer_argument, delay => Delay},
    S = 'Elixir.ExBench.Args':from_map(M),
    'Elixir.ExBench':run(S),
    ok.
