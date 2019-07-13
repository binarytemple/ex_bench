defmodule ExBench.FileProducerTest do
  use ExUnit.Case
  alias ExBench.FileProducer

  @get_example_consult_filename "#{List.to_string(:code.priv_dir(:ex_bench))}/example.consult"
  @file_producer_args %{filename: @get_example_consult_filename}

  test "test gen_stage producer" do
    Process.flag(:trap_exit, true)

    {:ok, gs} = GenStage.start_link(FileProducer, @file_producer_args)

    pull = fn count ->
      GenStage.stream([{gs, max_demand: 1, cancel: :temporary}]) |> Enum.take(count)
    end

    assert length(pull.(5)) == 5
    assert length(pull.(5)) == 4
    assert length(pull.(5)) == 0

    assert_receive {:EXIT, gs, :empty}
  end
end
