defmodule BestestIfTest do
  use ExUnit.Case
  doctest BestestIf

  test "greets the world" do
    assert BestestIf.hello() == :world
  end
end
