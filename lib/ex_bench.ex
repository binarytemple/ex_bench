defmodule ExBench.Args do
  @delay 1000
  @default_filename "#{List.to_string(:code.priv_dir(:ex_bench))}/example.consult"
  def example_fun(x) do
    IO.inspect(x)
  end

  defstruct workers: 10,
            overflow: 2,
            concurrency: 3,
            bench_fun: &ExBench.Args.example_fun/1,
            producer: ExBench.FileProducer,
            producer_argument: %{filename: @default_filename},
            delay: @delay

  def from_map(m) when is_map(m) do
    struct(__MODULE__, m)
  end
end

defmodule ExBench do
  require Logger

  def stop(), do: DynamicSupervisor.stop(ExBench.DynamicSupervisor)

  # def run(
  #       workers,
  #       overflow,
  #       concurrency,
  #       bench_fun,
  #       producer,
  #       producer_argument,
  #       delay
  #     )
  #     when is_map(producer_argument) do
  #   args = %ExBench.Args{
  #     workers: workers,
  #     overflow: overflow,
  #     concurrency: concurrency,
  #     bench_fun: bench_fun,
  #     producer: producer,
  #     producer_argument: producer_argument,
  #     delay: delay
  #   }

  #   run(args)
  # end

  def run(args \\ %ExBench.Args{}) do
    conf = Map.from_struct(args)
    # conf[:bench_fun].("HELLO WORLD")
    ExBench.DynamicSupervisor.start_child(generate_poolboy_spec(conf[:bench_fun]))
    ExBench.DynamicSupervisor.start_child({ExBench.Signaler, conf})
  end

  defp generate_poolboy_spec(
         bench_fun,
         config \\ [
           name: {:local, :worker},
           worker_module: ExBench.Worker,
           size: 10,
           max_overflow: 10
         ]
       ) do
    %{
      id: :poolboy,
      start:
        {:poolboy, :start_link,
         [
           config,
           bench_fun
         ]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
