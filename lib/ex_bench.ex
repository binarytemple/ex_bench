defmodule ExBench do
  require Logger
  @delay 1000

  def default_filename(), do: "#{List.to_string(:code.priv_dir(:ex_bench))}/example.consult"

  defp poolboy_config do
    [
      {:name, {:local, :worker}},
      {:worker_module, ExBench.Worker},
      {:size, Application.get_env(:ex_bench, :workers)},
      {:max_overflow, Application.get_env(:ex_bench, :overflow)}
    ]
  end

  @spec run(bench_fun: function(), filename: String.t()) ::
          :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def run(args \\ [bench_fun: fn x -> IO.inspect(x) end, filename: default_filename()])
      when is_list(args) do
    conf = %{
      workers: 10,
      overflow: 2,
      concurrency: 3,
      bench_fun: args[:bench_fun],
      producer: ExBench.FileProducer,
      producer_argument: %{filename: args[:filename]},
      delay: @delay
    }

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
