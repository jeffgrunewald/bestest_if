defmodule BestestIf do
  require Logger

  defmacro __using__(_) do
    quote do
      import BestestIf
    end
  end

  defmacro if!(expression, [do: do_block]) do
    function = {:fn, [], [{:->, [], [[], do_block]}]}
    quote do
      execute(unquote(expression), unquote(function))
    end
  end

  def execute(expression, function) do
    BestestIf.Writer.start_link()
    BestestIf.Loader.start_link()

    Process.sleep(500)

    "BestestIf.Runner"
    |> Code.eval_string()
    |> (fn {module, []} -> module end).()
    |> Code.ensure_loaded()
    |> case do
         {:module, _} ->
           {:ok, pid} = apply(BestestIf.Runner, :start, [[expression: expression, function: function]])
           GenServer.call(pid, :run)
         {:error, _} ->
           Logger.error("Code did not load successfully")
       end
  end
end
