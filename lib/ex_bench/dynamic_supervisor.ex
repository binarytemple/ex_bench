defmodule ExBench.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(spec) do
    # If MyWorker is not using the new child specs, we need to pass a map:
    # spec = %{id: MyWorker, start: {MyWorker, :start_link, [foo, bar, baz]}}
    # spec = {MyWorker, foo: foo, bar: bar, baz: baz}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @doc """
  And this is the contortion you have to go through to get DynamicSupervisor to spawn children at init.
  """
  @impl true
  def init(args) when is_list(args) do
    ret =
      DynamicSupervisor.init(
        strategy: :one_for_one,
        extra_arguments: []
      )

    args
    |> Enum.each(fn spec ->
      spawn_link(fn -> ExBench.DynamicSupervisor.start_child(spec) end)
    end)

    ret
  end
end
