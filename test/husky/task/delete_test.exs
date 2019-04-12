defmodule Husky.Task.DeleteTest do
  import ExUnit.CaptureIO
  use ExUnit.Case, async: false
  alias Mix.Tasks.Husky.{Delete, Install}
  alias Husky.{TestHelper, Util}

  @delete_message """
  ... running husky delete
  """

  setup do
    TestHelper.initialize_empty_git_hook_directory()
    capture_io(&Install.run/0)
    :ok
  end

  describe "Mix.Tasks.Husky.Delete.run" do
    test "should delete all git hooks and the .git/hooks directory" do
      assert 19 == Util.git_hooks_directory() |> File.ls!() |> length()
      assert @delete_message == capture_io(&Delete.run/0)
      assert {:error, :enoent} == File.ls(Util.git_hooks_directory())
    end
  end
end
