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
    Process.send_after(self(), {:work, :erlang.system_time()}, @delay)
    {:ok, nil}
  end

  @impl true
  def handle_info({:work, invoked}, state) do
    # Do the desired work here
    # Reschedule once more
    drift = (:erlang.system_time() - invoked - @delay * 1_000_000) / 1_000_000
    corrected = @delay - :erlang.round(drift)

    Process.send_after(self(), {:work, :erlang.system_time()}, corrected)
    Logger.debug("drift :  #{drift},  corrected: #{corrected} ")

    workers = Application.get_env(:poc_event_timer, :workers)

    handles =
      1..workers
      |> Enum.map(fn _ ->
        Task.async(fn ->
          :poolboy.transaction(
            :worker,
            fn pid -> GenServer.cast(pid, :do_work) end,
            @timeout
          )
        end)
      end)

    handles |> Enum.each(&Task.await(&1))

    {:noreply, state}
  end

  @impl true
  def handle_info(x, state) do
    IO.puts("handle_info: #{inspect(x)}")
    {:noreply, state}
  end
end
