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
  @timeout 60000
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_cast(:next, state) do
    IO.puts("time : #{:erlang.system_time()}")
    Task.async(fn ->
      :poolboy.transaction(
        :worker,
        fn pid -> GenServer.call(pid, {:square_root, 8}) end,
        @timeout
      )
    end
    )
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

  def handle_call({:square_root, x}, _from, state) do
    IO.puts("process #{inspect(self())} calculating square root of #{x}")
    :timer.sleep(1000)
    {:reply, :math.sqrt(x), state}
  end
end
