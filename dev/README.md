# Husky Developer's Guide

## How it Works
### Install
When husky is compiled, it manually executes `mix husky.install` ([husky.install source](../lib/husky/task/install.ex)), which generates and installs a  bash script for every possible "git hook" ([list of supported git hooks](../lib/husky/util/util.ex)) in the user's `.git/hooks` directory. 

### Runtime
When a git command is executed (`git commit`) it executes the appropriate git hook script (`.git/hooks/pre-commit`) which was installed by husky.

The git hook script, that was installed by husky, executes an escript ([source](../lib/escript.ex), [compiled](../priv/husky)), which manually invokes `mix husky.execute $GIT_ARGS` ([husky.execute source](../lib/husky/task/execute.ex)). 

`husky.execute` parses config files and executes the user specified commands. `husky.execute` returns the same exit code as the command executed. 

If the command executed returns a successful exit code (`0`) then the git command wil also be executed, otherwise it will fail.

### Summary
1. On compile, Husky installs git-hook scripts
1. User invokes a git command (`git commit -m "my great commit"`)
1. A git-hook script is triggered (`.git/hooks/pre-commit`)
1. The git-hook script calls an escript (`priv/husky`)
1. The escript calls a mix task (`mix husky.execute`)
1. The mix task executes user-specified command from configs (`config :husky, pre_push: "mix format --check-formatted"`)
1. The exit code of user-specified command is returned to git, which dictates if the git command will be executed
 
* **Build** - `rm priv/husky && MIX_ENV=prod mix escript.build`
    * If you don't run `rm` the escript size continues to grow
* **Install** 
    * install hook scripts in [sandbox](./sandbox) directory
    ```bash
    rm -rf dev/sandbox/.git/ && \       # clean up
    (cd dev/sandbox && git init) && \   # create git                          
    MIX_ENV=test mix husky.install && \ # install scripts
    (cd dev/sandbox && git commit)      # run git commands
    ```
    * See [test_helper.exs](../test/test_helper.exs) for an example of how to set up a fake "remote" to test `git push`
    * You can also point any repo to a local version of husky using the `:path` option in your mix.esx file and pointing it to your local install of husky. You will also have to set the `:host_path` and `:escript_path` configs for husky.
* **Delete** 
    * delete hook scripts from sandbox `MIX_ENV=test mix husky.delete`
* **Git Hooks** 
    * execute git hooks manually via mix task - `MIX_ENV=test mix husky.execute pre_commit`
    * execute git hooks manually via escript - `MIX_ENV=test ./priv/husky pre_commit`
    
## Publishing
travis CI is set up to automatically publish a new version to hex when a new git tag is pushed.
```bash
git tag -a 1.0.3 -m "testing auto deploy to hex" # create annotated git tag
git push origin --tags                           # push tag, trigger build and deploy to hex
```
        
## Helpful Resources
* [githooks documentation](https://git-scm.com/docs/githooks)
