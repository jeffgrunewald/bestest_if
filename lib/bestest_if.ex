defmodule BestestIf do
  alias BestestIf.Executer

  defmacro __using__(_) do
    quote do
      import BestestIf
    end
  end

  defmacro if!(expression, do: do_block) do
    quote do
      if_task = Task.async(fn ->
        receive do
          :do_it ->
            unquote(do_block)
          :dont_do_it ->
            nil
        end
      end)

      Executer.execute(unquote(expression), if_task.pid)

      Task.await(if_task, :infinity)
    end
  end
end

