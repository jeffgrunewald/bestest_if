defmodule BestestIf.Loader do
  use Task

  defmacro __using__(_) do
    quote do
      unquote(Application.put_env(:bestest_if, :if_ref, If))

      import unquote(Application.get_env(:bestest_if, :if_ref))
    end
  end

  def start_link(args \\ []) do
    Task.start_link(__MODULE__, :load, [args])
  end

  def load(args) do
      temp_dir = get_tempdir(args)

      attempt_read(temp_dir)
    rescue
      Code.LoadError ->
        Process.sleep(100)
        temp_dir = get_tempdir(args)
        attempt_read(temp_dir)
  end

  defp get_tempdir(args) do
    temp_finder = fn -> System.get_env("TMPDIR") || "/tmp" end

    Keyword.get_lazy(args, :temp, temp_finder)
  end

  defp attempt_read(dir) do
    Code.compile_file("#{dir}/best_if_ever.ex")
    Code.compile_file("#{dir}/bestest_if_runner.ex")
  end
end
