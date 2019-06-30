defmodule Husky.TestHelper do
  use Constants
  alias Husky.Util
  require Util

  define(git_default_scripts, [
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
  ])

  define(all_scripts, Enum.sort(git_default_scripts() ++ Util.hooks()))

  @doc """
  Remove and create a blank local git repository in dev/sandbox
  """
  def initialize_local(dir \\ Util.host_path()) do
    """
    rm -rf #{dir} && \
    mkdir -p #{dir} && \
    cd #{dir} && \
    git init
    """
    |> to_charlist()
    |> :os.cmd()
  end

  @doc """
  Create a fake remote repository in dev/remote and configure
  the dev/sandbox repository to have dev/remote as an origin repository
  add a test file, an initial commit, and push the commit to remote to 
  make sure it is working 
  """
  def initialize_remote(host_path \\ Util.host_path()) do
    remote_dir = Path.expand("../remote", host_path)
    remote_git_dir = Path.expand(".git", remote_dir)

    # remove and re-create remote directory
    """
    rm -rf #{remote_dir} && \
    mkdir -p #{remote_git_dir}
    """
    |> to_charlist()
    |> :os.cmd()

    # initialize git in "remote"
    """
    cd #{remote_dir} && \
    git init --bare #{remote_git_dir}
    """
    |> to_charlist()
    |> :os.cmd()

    # add a local "remote" as origin to host
    """
    cd #{host_path} && \
    git remote add origin #{remote_git_dir} && \
    touch dummy.txt && \
    git add dummy.txt && \
    git commit -am 'init commit' --no-verify && \
    git push --set-upstream origin master --no-verify
    """
    |> to_charlist()
    |> :os.cmd()
    |> to_string()
  end
end

ExUnit.start()
