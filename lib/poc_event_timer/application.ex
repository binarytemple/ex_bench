defmodule PocEventTimer.Application do
  @moduledoc false

  use Application
  require Logger
  @delay 1000

  def poolboy_config do
    [
      {:name, {:local, :worker}},
      {:worker_module, PocEventTimer.Worker},
      {:size, Application.get_env(:poc_event_timer, :workers)},
      {:max_overflow, Application.get_env(:poc_event_timer, :overflow)}
    ]
  end

  def signaller_config() do
    %{
      bench_fun: Application.get_env(:poc_event_timer, :bench_fun),
      producer: Application.get_env(:poc_event_timer, :producer),
      producer_args: Application.get_env(:poc_event_timer, :producer_args),
      concurrency: Application.get_env(:poc_event_timer, :concurrency),
      delay: @delay
    }
  end

  def bench_fun_config() do
    Application.get_env(:poc_event_timer, :bench_fun)
  end

  def start(type, args) do
    Logger.info("#{__MODULE__} start(#{inspect([type, args])})")
    children = [
      :poolboy.child_spec(:worker, poolboy_config(),  bench_fun_config()),
      {PocEventTimer.Signaler,  signaller_config() }
    ]
    opts = [strategy: :one_for_one, name: PocEventTimer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def stop() do
    Supervisor.stop(PocEventTimer.Supervisor)
    Application.stop(:poc_event_timer)
  end
end
