defmodule Husky.Script do
  @moduledoc """
  Struct to represent a [git hook script](https://git-scm.com/docs/githooks)
  """
  require Husky.Util
  alias Husky.Script
  alias Husky.Util

  defstruct path: nil, content: nil

  def new(hook) when is_binary(hook) do
    %Script{path: Path.join(Util.git_hooks_directory(), hook)}
  end

  def add_content(%Script{} = script) do
    content = """
    #!/usr/bin/env sh
    # #{Util.app()}
    # #{Util.version()} #{
      :os.type()
      |> Tuple.to_list()
      |> Enum.map(&Atom.to_string/1)
      |> Enum.map(fn s -> s <> " " end)
    }
    #{if Mix.env() == :test, do: "export MIX_ENV=test"}
    SCRIPT_PATH=\"#{Util.escript_path()}\"
    HOOK_NAME=`basename \"$0\"`
    GIT_PARAMS=\"$*\"

    if [ \"${HUSKY_DEBUG}\" = \"true\" ]; then
      echo \"husky:debug $HOOK_NAME hook started...\"
    fi

    if [ -f $SCRIPT_PATH ]; then
      $SCRIPT_PATH $HOOK_NAME \"$GIT_PARAMS\"
    else
      echo \"Can not find Husky escript. Skipping $HOOK_NAME hook\"
      echo \"You can reinstall husky by running mix husky.install\"
    fi
    """

    %Script{script | content: content}
  end
end
