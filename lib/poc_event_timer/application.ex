defmodule PocEventTimer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  defp poolboy_config do
    [
      {:name, {:local, :worker}},
      {:worker_module, PocEventTimer.Worker},
      {:size, Application.get_env(:poc_event_timer, :workers)},
      {:max_overflow, Application.get_env(:poc_event_timer, :overflow)}
    ]
  end

  def start(_type, _args) do
    children = [
      :poolboy.child_spec(:worker, poolboy_config()),
      {PocEventTimer.Signaler, []}
    ]

    opts = [strategy: :one_for_one, name: PocEventTimer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
