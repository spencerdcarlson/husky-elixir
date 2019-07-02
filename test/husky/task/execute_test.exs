defmodule Husky.Task.ExecuteTest do
  import ExUnit.CaptureIO
  require Logger
  use ExUnit.Case, async: false
  alias Mix.Tasks.Husky.Install
  alias Husky.{TestHelper, Util}

  setup do
    TestHelper.initialize_local()
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
               ~r/husky > pre-push origin .*? \('false'\) failed \(add --no-verify to bypass\)/
             )

      assert result =~ "failed"
    end

    test "given a custom config it override existing configs" do
      file =
        """
        use Mix.Config
        config :husky,
          host_path: "./dev/sandbox",
          escript_path: "./priv/husky",
          pre_commit: "false"
        """
        |> to_tmp_file()

      result =
        """
        mix husky.execute pre-commit -c #{file}
        """
        |> to_charlist()
        |> :os.cmd()
        |> to_string()

      File.rm(file)

      assert String.match?(
               result,
               ~r/husky > pre-commit \('false'\) failed \(add --no-verify to bypass\)/
             )

      result =~ "failed"
    end
  end

  defp to_tmp_file(contents) do
    random = :crypto.strong_rand_bytes(10) |> Base.url_encode64(padding: false)
    filename = Path.expand("#{random}.exs", "/tmp")

    case File.open(filename, [:write]) do
      {:ok, file} ->
        try do
          IO.binwrite(file, contents)
          filename
        after
          File.close(file)
        end

      error ->
        Logger.error(error)
    end
  end
end
