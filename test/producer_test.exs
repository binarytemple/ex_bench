defmodule ExBench.FileProducerTest do
  use ExUnit.Case
  alias ExBench.FileProducer

  test "test gen_stage producer" do
    Process.flag(:trap_exit, true)
    {:ok, gs} = GenStage.start_link(FileProducer, %{filename: "./test/consult.me"})

    pull = fn count ->
      GenStage.stream([{gs, max_demand: 1, cancel: :temporary}]) |> Enum.take(count)
    end

    assert length(pull.(5)) == 5
    assert length(pull.(5)) == 4
    assert length(pull.(5)) == 0

    assert_receive {:EXIT, gs, :empty}
  end
end
