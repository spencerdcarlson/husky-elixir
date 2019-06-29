defmodule Husky.Task.DeleteTest do
  import ExUnit.CaptureIO
  use ExUnit.Case, async: false
  alias Mix.Tasks.Husky.{Delete, Install}
  alias Husky.{TestHelper, Util}

  @delete_message """
  ... running husky delete
  """
  @sample_scripts [
    "commit-msg.sample",
    "pre-rebase.sample",
    "pre-commit.sample",
    "applypatch-msg.sample",
    "fsmonitor-watchman.sample",
    "pre-receive.sample",
    "prepare-commit-msg.sample",
    "post-update.sample",
    "pre-applypatch.sample",
    "pre-push.sample",
    "update.sample"
  ]

  setup do
    TestHelper.initialize_local()
    capture_io(&Install.run/0)
    :ok
  end

  describe "Mix.Tasks.Husky.Delete.run" do
    test "should delete all git hooks that were installed by husky" do
      assert 30 == Util.git_hooks_directory() |> File.ls!() |> length()
      assert @delete_message == capture_io(&Delete.run/0)
      assert {:ok, @sample_scripts} == File.ls(Util.git_hooks_directory())
      assert length(@sample_scripts) == Util.git_hooks_directory() |> File.ls!() |> length()
    end
  end
end
