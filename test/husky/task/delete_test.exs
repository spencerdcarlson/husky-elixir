defmodule Husky.Task.DeleteTest do
  import ExUnit.CaptureIO
  use ExUnit.Case, async: false
  alias Mix.Tasks.Husky.{Delete, Install}
  alias Husky.{TestHelper, Util}
  require TestHelper

  @delete_message """
  ... running husky delete
  """

  setup do
    TestHelper.initialize_local()
    capture_io(&Install.run/0)
    :ok
  end

  describe "Mix.Tasks.Husky.Delete.run" do
    test "should delete all git hooks that were installed by husky" do
      n_scripts = Util.git_hooks_directory() |> File.ls!() |> length()

      # Linux has 1 less default git script "fsmonitor-watchman.sample" exists on macOS but not on Linux
      assert length(TestHelper.all_scripts()) == n_scripts ||
               length(TestHelper.all_scripts()) - 1 == n_scripts

      assert @delete_message == capture_io(&Delete.run/0)

      scripts = Util.git_hooks_directory() |> File.ls!() |> Enum.sort()
      assert Enum.all?(scripts, fn e -> e in TestHelper.git_default_scripts() end)

      n_scripts = Util.git_hooks_directory() |> File.ls!() |> length()

      assert length(TestHelper.git_default_scripts()) == n_scripts ||
               length(TestHelper.git_default_scripts()) - 1 == n_scripts
    end
  end
end
