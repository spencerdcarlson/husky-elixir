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
      assert 30 == Util.git_hooks_directory() |> File.ls!() |> length()
      assert @delete_message == capture_io(&Delete.run/0)
      assert {:ok, TestHelper.git_default_scripts()} == File.ls(Util.git_hooks_directory())

      assert length(TestHelper.git_default_scripts()) ==
               Util.git_hooks_directory() |> File.ls!() |> length()
    end
  end
end
