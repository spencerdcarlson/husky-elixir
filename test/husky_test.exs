defmodule HuskyTest do
  use ExUnit.Case
  doctest Husky

  test "greets the world" do
    assert Husky.hello() == :world
  end
end
