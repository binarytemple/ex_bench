defmodule ExBench.FileProducer do
  use GenStage
  alias ExBench.FileProducer.LineParser
  require Logger

  def start_link(%{filename: filename}) do
    GenStage.start_link(A, %{filename: filename}, name: filename)
  end

  def init(%{filename: filename}) do
    # {:ok, fh} = File.open(filename, [{:read_ahead, 1024 * 1024}] )
    # {:ok, fh} = File.open(filename, [{:read_ahead, 1024 * 1024},:raw] )
    {:ok, fh} = File.open(filename)
    {:producer, fh}
  end

  def handle_demand(demand, fh) when demand > 0 do
    res = 1..demand |> Enum.map(fn _ -> :file.read_line(fh) end)

    ret =
      Enum.reduce(res, [], fn
        {:ok, x}, acc -> [LineParser.parse(x) | acc]
        :eof, acc -> acc
      end)

    case ret do
      [] ->
        File.close(fh)
        {:stop, :empty, :empty}

      ^ret ->
        {:noreply, ret, fh}
    end
  end
end
