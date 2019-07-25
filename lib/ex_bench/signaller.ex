defmodule ExBench.Signaler do
  use GenServer
  require Logger
  @timeout 60000

  def start_link(
        [],
        %{
          producer: _producer,
          producer_argument: _producer_argument,
          concurrency: _concurrency,
          delay: _delay,
          bench_fun: _bench_fun
        } = args
      ) do
    start_link(args)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  # def start_link(args), do: Logger.error("Bad args: #{inspect(args)}"); :error

  #  def  child_spec(init_arg) do
  #   IO.puts("child spec called!!! #{inspect(init_arg)}")
  #  end

  defp start_link_producer(producer, producer_argument) do
    {:ok, gs} = GenStage.start_link(producer, producer_argument)
    gs
  end

  @impl true
  def init(
        %{
          producer: producer,
          producer_argument: producer_argument,
          concurrency: concurrency,
          delay: delay
        } = args
      ) do
    Logger.debug("starting #{__MODULE__} , #{inspect(args)}")
    producer = start_link_producer(producer, producer_argument)
    Process.send_after(self(), {:work, :erlang.system_time()}, delay)
    {:ok, %{producer: producer, concurrency: concurrency, delay: delay}}
  end

  @impl true
  def handle_info(
        {:work, invoked},
        %{producer: producer, concurrency: concurrency, delay: delay} = state
      ) do
    Logger.debug("handle_info: #{inspect([{:work, invoked}, state])}")

    drift = (:erlang.system_time() - invoked - delay * 1_000_000) / 1_000_000
    corrected = delay - :erlang.round(drift)

    Process.send_after(self(), {:work, :erlang.system_time()}, corrected)
    Logger.debug("drift :  #{drift},  corrected: #{corrected} ")

    params =
      GenStage.stream([{producer, max_demand: 1, cancel: :temporary}]) |> Enum.take(concurrency)

    handles =
      params
      |> Enum.map(fn i ->
        Task.async(fn ->
          :poolboy.transaction(
            :worker,
            fn pid -> GenServer.cast(pid, {:do_work, i}) end,
            @timeout
          )
        end)
      end)

    handles |> Enum.each(&Task.await(&1))

    {:noreply, state}
  end

  @impl true
  def handle_info(x, state) do
    Logger.debug("handle_info: #{inspect(x)}")
    {:noreply, state}
  end
end
