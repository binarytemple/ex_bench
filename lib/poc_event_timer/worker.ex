defmodule PocEventTimer.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_cast({:do_work,data}, state) do
    bench_fun = Application.get_env(:poc_event_timer, :bench_fun)
    IO.puts("do_work: #{:erlang.system_time()}")
    bench_fun.(data)
    {:noreply, state}
  end
end
