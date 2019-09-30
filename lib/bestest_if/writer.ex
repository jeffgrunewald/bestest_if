defmodule BestestIf.Writer do
  use Task

  def start_link(args \\ []) do
    Task.start_link(__MODULE__, :write, [args])
  end

  def write(args) do
    temp_finder = fn -> System.get_env("TMPDIR") || "/tmp" end

    temp_dir = Keyword.get_lazy(args, :temp, temp_finder)

    File.write!("#{temp_dir}/best_if_ever.ex", BestestIf.RuntimeCode.best_if_code())
    File.write!("#{temp_dir}/bestest_if_runner.ex", BestestIf.RuntimeCode.bestest_if_runner_code())
  end
end
