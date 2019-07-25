defmodule ExBench.Worker do
  use GenServer

  alias ExBench.Metrics.CommandInstrumenter

  def start_link(bench_fun) do
    GenServer.start_link(__MODULE__, bench_fun, [])
  end

  @spec init(any) :: {:ok, any}
  def init(bench_fun) do
    {:ok, bench_fun}
  end

  def handle_cast({:do_work, data}, bench_fun) do
    CommandInstrumenter.counter_inc(%{command: "allocated_work"})
    bench_fun.(data)
    CommandInstrumenter.counter_inc(%{command: "processed_work"})
    {:noreply, bench_fun}
  end
end
