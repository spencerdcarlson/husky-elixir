defmodule Husky.Task.InstallTest do
  use ExUnit.Case
    alias Mix.Tasks.Husky.Install
    alias Husky.{Util, TestHelper}


  setup do
    # Delete all scripts in sandbox
      TestHelper.rm_files()
    :ok
  end


  describe "Mix.Tasks.Husky.Install.run" do
    test "should create a file fore each supported git hook" do
      Install.run()

      installed_hooks = File.ls!(Util.git_hooks_directory())

      assert ["pre-rebase", "pre-applypatch", "pre-auto-gc", "update", "post-receive",
        "post-commit", "push-to-checkout", "sendemail-validate", "applypatch-msg",
        "post-update", "prepare-commit-msg", "post-checkout", "post-applypatch",
        "post-rewrite", "pre-receive", "commit-msg", "pre-push", "post-merge",
        "pre-commit"] == installed_hooks
    end

    test "should create scripts with the correct content" do
      Install.run()

      content =
      Util.git_hooks_directory()
      |> Path.join("pre-commit")
      |> File.read!()

      assert """
      #!/usr/bin/env sh
      # husky
      # 1.0.0 unix darwin\s
      export MIX_ENV=test
      SCRIPT_PATH="./priv/husky"
      HOOK_NAME=`basename "$0"`
      GIT_PARAMS="$*"

      if [ "${HUSKY_DEBUG}" = "true" ]; then
        echo "husky:debug $HOOK_NAME hook started..."
      fi

      if [ -f $SCRIPT_PATH ]; then
        $SCRIPT_PATH $HOOK_NAME "$GIT_PARAMS"
      else
        echo "Can not find Husky escript. Skipping $HOOK_NAME hook"
        echo "You can reinstall husky by running mix husky.install"
      fi
      """ == content
    end
  end

  describe "Mix.Tasks.Husky.Install.__after_compile__" do
    test "should create a file fore each supported git hook" do
      Install.__after_compile__(nil, nil)
      installed_hooks = File.ls!(Util.git_hooks_directory())

      assert ["pre-rebase", "pre-applypatch", "pre-auto-gc", "update", "post-receive",
               "post-commit", "push-to-checkout", "sendemail-validate", "applypatch-msg",
               "post-update", "prepare-commit-msg", "post-checkout", "post-applypatch",
               "post-rewrite", "pre-receive", "commit-msg", "pre-push", "post-merge",
               "pre-commit"] == installed_hooks
    end

    test "should respect the HUSKY_SKIP_INSTALL flag" do
      System.put_env("HUSKY_SKIP_INSTALL", "true")
      Install.__after_compile__(nil, nil)
      refute Util.git_hooks_directory() |> Path.join("pre-commit") |> File.exists?()
    end
  end



end
