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
    use GenServer
    use BestestIf.Loader

    def start(args) do
      GenServer.start(__MODULE__, args)
    end

    def init(args) do
      Process.flag(:trap_exit, true)

      temp_finder = fn -> System.get_env("TMPDIR") || "/tmp" end

      state = %{
        expression: Keyword.fetch!(args, :expression),
        function: Keyword.fetch!(args, :function),
        temp_dir: Keyword.get_lazy(args, :temp, temp_finder)
      }

      {:ok, state}
    end

    def handle_call(:run, _, %{expression: exp, function: fun} = state) do
      response = if? exp, do: self()
      Process.send(self(), :die, [])
      {:reply, response, state}
    end

    def handle_cast(:do, %{function: fun} = state) do
      fun.()
      {:noreply, state}
    end

    def handle_info(:die, state) do
      Process.sleep(2_000)
      {:stop, :finished, state}
    end

    def terminate(:finished, %{temp_dir: temp}) do
      File.rm("#{temp}/best_if_ever.ex")
      File.rm("#{temp}/bestest_if_runner.ex")
    end
  end
  """

  def best_if_code(), do: @best_if_code

  def bestest_if_runner_code(), do: @bestest_if_runner_code
end
