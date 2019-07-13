defmodule PocEventTimer.Worker do
  use GenServer

  def start_link(bench_fun) do
    GenServer.start_link(__MODULE__, bench_fun, [])
  end

  def init(bench_fun) do
    {:ok, bench_fun}
  end

  def handle_cast({:do_work, data}, bench_fun) do
    bench_fun.(data)
    {:noreply, bench_fun}
  end
end
