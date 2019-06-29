defmodule Husky.Task.ExecuteTest do
  import ExUnit.CaptureIO
  use ExUnit.Case, async: false
  alias Mix.Tasks.Husky.Install
  alias Husky.{TestHelper, Util}

  setup do
    TestHelper.initialize_empty_git_hook_directory()
    capture_io(&Install.run/0)
    TestHelper.initialize_remote()
    :ok
  end

  # credo:disable-for-this-file
  describe "Mix.Tasks.Husky.Execute.run" do
    test "running `git commit` should trigger the command in Application.get_env(:husky, :pre_commit)" do
      result =
        """
        cd #{Util.host_path()} && \
        touch file1.txt && \
        git add file1.txt && \
        git commit -m 'test'
        """
        |> to_charlist()
        |> :os.cmd()
        |> to_string()

      number_of_commits =
        """
        cd #{Util.host_path()} && \
        git rev-list --all --count
        """
        |> to_charlist()
        |> :os.cmd()
        |> to_string()
        |> Integer.parse()
        |> elem(0)

      refute result =~ "failed"
      assert result =~ "husky > pre-commit ('mix -v')"
      # TestHelper.initialize_remote() adds 'initial commit'
      assert 2 == number_of_commits
    end

    test "running `git push` should trigger Application.get_env(:husky, :pre_push)" do
      result =
        "cd #{Util.host_path()} && git push"
        |> to_charlist()
        |> :os.cmd()
        |> to_string()

      assert String.match?(
               result,
               ~r/husky > pre-push origin .*? \('false'\) failed \(cannot be bypassed with --no-verify due to Git specs\)/
             )

      assert result =~ "failed"
    end
  end
end
