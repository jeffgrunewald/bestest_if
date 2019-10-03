defmodule BestestIf.RuntimeCode do

  @best_if_code ~S"""
  defmodule If.Server do
    use GenServer, restart: :transient

    def start(args) do
      GenServer.start(__MODULE__, Map.new(args))
    end

    def init(%{expression: exp} = state) do
      {:ok, {! not exp, Map.get(state, :function)}, {:continue, not not ! exp}}
    end

    def handle_continue(:false, {true, function}) do
      function.()
      {:stop, true, :ok}
    end

    def handle_continue(:true, {false, _}) do
      {:stop, false, :ok}
    end
  end

  defmodule If do

    defmacro __using__(_opts) do
      quote do
        import If
      end
    end

    defmacro if?(expression, [do: do_block]) do
      function = {:fn, [], [{:->, [], [[], do_block]}]}
      quote do
        retry = fn fun, pid ->
          case Process.alive?(pid) do
            true -> fun.(fun, pid)
            false -> :ok
          end
        end
        {:ok, pid} = If.Server.start(expression: unquote(expression), function: unquote(function))
        retry.(retry, pid)
      end
    end
  end
  """

  @bestest_if_runner_code ~S"""
  defmodule BestestIf.Runner do
    require Logger
    use GenServer, restart: :transient
    use BestestIf.Loader

    def start(args) do
      GenServer.start(__MODULE__, args)
    end

    def init(args) do
      Process.flag(:trap_exit, true)

      temp_finder = fn -> System.get_env("TMPDIR") || "/tmp" end

      state = %{
        expression: Keyword.fetch!(args, :expression),
        task: Keyword.fetch!(args, :task),
        temp_dir: Keyword.get_lazy(args, :temp, temp_finder)
      }

      {:ok, state}
    end

    def handle_cast(:run, %{expression: expression, task: task} = state) do
      if? expression, do: send(task, :do_it)

      if? ! expression, do: send(task, :dont_do_it)
      {:stop, :normal, state}
    end

    def terminate(:normal, %{temp_dir: temp}) do
      File.rm("#{temp}/best_if_ever.ex")
      File.rm("#{temp}/bestest_if_runner.ex")
    end
  end
  """

  def best_if_code(), do: @best_if_code

  def bestest_if_runner_code(), do: @bestest_if_runner_code
end
