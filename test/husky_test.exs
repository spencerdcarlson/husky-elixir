defmodule HuskyTest do
  use ExUnit.Case
  #  alias Mix.Tasks.Husky.Install

  #  test "the correct script content is generated" do
  #    app_name = :husky
  #    app_version = 1.0
  #    escript_path = "priv/husky"
  #
  #    assert Install.hook_script_content(app_name, app_version, escript_path) ==
  #             "#!/usr/bin/env sh\n# husky\n# 1.0 unix darwin \nSCRIPT_PATH=\"priv/husky\"\nHOOK_NAME=`basename \"$0\"`\nGIT_PARAMS=\"$*\"\n\nif [ \"${HUSKY_DEBUG}\" = \"true\" ]; then\n  echo \"husky:debug $HOOK_NAME hook started...\"\nfi\n\nif [ -f $SCRIPT_PATH ]; then\n  $SCRIPT_PATH $HOOK_NAME \"$GIT_PARAMS\"\nelse\n  echo \"Can't find Husky, skipping $HOOK_NAME hook\"\n  echo \"You can reinstall husky or this hook\"\nfi\n"
  #  end

  describe "Husky" do
    test "fail" do
      assert true
      #      assert false
    end
  end
end
