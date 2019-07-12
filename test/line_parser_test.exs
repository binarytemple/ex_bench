defmodule PocEventTimer.LineParserTest do
  use ExUnit.Case
  alias PocEventTimer.LineParser

  test "test line parser" do
    x = LineParser.parse(~S({test1,{"61", <<7,166>>, #{},[],false, #{<<"x">> => <<"y">>}}}.))

    assert {:test1, {'61', <<7, 166>>, %{}, [], false, %{"x" => "y"}}} = x
  end
end
