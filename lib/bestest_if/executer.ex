defmodule BestestIf.Executer do
  require Logger
  alias BestestIf.{Writer,Loader}

  def execute(expression, task) do
    Writer.start_link()
    Loader.start_link()

    Process.sleep(500)

    "BestestIf.Runner"
    |> Code.eval_string()
    |> (fn {module, []} -> module end).()
    |> Code.ensure_loaded()
    |> case do
         {:module, _} ->
           {:ok, pid} = apply(BestestIf.Runner, :start, [[expression: expression, task: task]])
           GenServer.cast(pid, :run)
         {:error, _} ->
           Logger.error("Code did not load successfully")
       end
  end
end
