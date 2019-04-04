defmodule Constants do
  @moduledoc """
  An alternative to use @constant_name value approach to defined reusable
  constants in elixir.
  This module offers an approach to define these in a
  module that can be shared with other modules. They are implemented with
  macros so they can be used in guards and matches
  ## Examples:
  Create a module to define your shared constants
      defmodule MyConstants do
        use Constants
        define something,   10
        define another,     20
      end
  Use the constants
      defmodule MyModule do
        require MyConstants
        alias MyConstants, as: Const
        def myfunc(item) when item == Const.something, do: Const.something + 5
        def myfunc(item) when item == Const.another, do: Const.another
      end
  """

  defmacro __using__(_opts) do
    quote do
      import Constants
    end
  end

  @doc "Define a constant"
  defmacro constant(name, value) do
    quote do
      defmacro unquote(name), do: unquote(value)
    end
  end

  @doc "Define a constant. An alias for constant"
  defmacro define(name, value) do
    quote do
      constant(unquote(name), unquote(value))
    end
  end
end
