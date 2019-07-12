defmodule PocEventTimer.LineParser do
  def parse({:ok, line}), do: parse(line)

  def parse(line) do
    input = :erlang.binary_to_list(line)
    {:ok, toks, _} = :erl_scan.string(input)
    {:ok, exprs} = :erl_parse.parse_exprs(toks)
    {:value, terms, _} = :erl_eval.exprs(exprs, :orddict.new())
    terms
  end
end
