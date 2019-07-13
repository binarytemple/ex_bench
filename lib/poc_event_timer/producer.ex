defmodule PocEventTimer.Producer do
  use GenStage
  alias PocEventTimer.LineParser

  def start_link(%{filename:  filename}) do
    GenStage.start_link(A, %{filename:  filename})
  end

  def init(%{filename:  filename}) do
    {:ok, fh} = File.open(filename)
    {:producer, fh}
  end

  # def handle_demand(demand, fh) when demand > 0 do
  def handle_demand(demand, fh) when demand > 0 do
    # IO.puts("demand: #{demand}  fh: #{inspect(fh)}" )
    res = 1..demand |> Enum.map(fn _ -> :file.read_line(fh) end)

    # IO.inspect(res)
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
