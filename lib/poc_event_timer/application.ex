defmodule PocEventTimer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  defp poolboy_config do
    [
      {:name, {:local, :worker}},
      {:worker_module, PoolboyApp.Worker},
      {:size, Application.get_env(:poc_event_timer, :workers)},
      {:max_overflow, Application.get_env(:poc_event_timer, :overflow)}
    ]
  end

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: PocEventTimer.Worker.start_link(arg)
      # {PocEventTimer.Worker, arg}
      :poolboy.child_spec(:worker, poolboy_config()),
      {PocEventTimer.Signaler, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PocEventTimer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
