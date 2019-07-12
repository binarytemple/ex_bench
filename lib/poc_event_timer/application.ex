defmodule PocEventTimer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  defp poolboy_config do
    [
      {:name, {:local, :worker}},
      {:worker_module, PoolboyApp.Worker},
      {:size, 5},
      {:max_overflow, 2}
    ]
  end

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: PocEventTimer.Worker.start_link(arg)
      # {PocEventTimer.Worker, arg}
      :poolboy.child_spec(:worker, poolboy_config()),
      {PocEventTimer.Signaler, [] }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PocEventTimer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end



defmodule PocEventTimer.Signaler do
  use GenServer
  require Logger
  @timeout 60000
  @delay 1000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    IO.puts("starting #{__MODULE__}")
    Process.send_after(self(), { :work, :erlang.system_time()}, @delay)
    {:ok, nil}
  end

  @impl true
  def handle_info({:work,invoked}, state) do
    # Do the desired work here
    # Reschedule once more
    drift = ((:erlang.system_time() - invoked)  - @delay * 1_000_000) / 1_000_000
    rounded = :erlang.round(1000875000 / 1000_000)
    corrected =  @delay  - :erlang.round(drift)

    Process.send_after(self(), { :work, :erlang.system_time()}, corrected)
    Logger.debug("drift :  #{drift},  corrected: #{corrected} ")
    Task.async(fn ->
      :poolboy.transaction(
        :worker,
        fn pid -> GenServer.cast(pid, :do_work) end,
        @timeout
      )
    end
    )
    {:noreply, state}
  end

  @impl true
  def handle_info(x, state) do
    IO.puts("handle_info: #{inspect(x)}")
    {:noreply, state}
  end



end




defmodule PoolboyApp.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_cast(:do_work,  state) do
    IO.puts("do_work: #{:erlang.system_time()}")
    {:noreply, state}
  end
end
