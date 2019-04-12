defmodule Husky.Task.ExecuteTest do
  import ExUnit.CaptureIO
  use ExUnit.Case, async: false
  alias Mix.Tasks.Husky.Install
  alias Husky.{TestHelper, Util}

  setup do
    TestHelper.initialize_empty_git_hook_directory()
    capture_io(&Install.run/0)
    :ok
  end

  # credo:disable-for-this-file
  describe "Mix.Tasks.Husky.Execute.run" do
    test "running `git commit` should trigger `mix husk.execute pre-commit` and successfully run configured hooks" do
      result =
        "cd #{Util.host_path()} && git commit"
        |> to_charlist()
        |> :os.cmd()
        |> to_string()

      refute result =~ "failed"
    end
  end
end
