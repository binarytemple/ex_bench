defmodule PocEventTimer.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_cast(:do_work, state) do
    IO.puts("do_work: #{:erlang.system_time()}")
    {:noreply, state}
  end
end
