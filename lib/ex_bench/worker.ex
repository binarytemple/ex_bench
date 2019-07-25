defmodule ExBench.Worker do
  use GenServer

  def start_link(bench_fun) do
    GenServer.start_link(__MODULE__, bench_fun, [])
  end

  @spec init(any) :: {:ok, any}
  def init(bench_fun) do
    # IO.puts("init : bench_fun: #{inspect(bench_fun)}")
    {:ok, bench_fun}
  end

  def handle_cast({:do_work, data}, bench_fun) do
    :telemetry.execute([:ex_bench, :worker], 1, %{command: "allocated_work"})
    bench_fun.(data)
    :telemetry.execute([:ex_bench, :worker], 1, %{command: "processed_work"})
    {:noreply, bench_fun}
  end
end
