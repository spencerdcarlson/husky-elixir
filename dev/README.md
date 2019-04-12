## Development

## Overview
The [husky.install](../lib/husky/task/install.ex) mix task will generate a and install a default bash script in the `.git/hooks` directory
for every possible git hook (see `hooks` in [Husky.Util](../lib/husky/util/util.ex)) These husky hook scripts will invoke the [escript](../lib/escript.ex) that gets packaged in `priv/husky`. 
The escript invokes the [husky.execute](../lib/husky/task/execute.ex) mix task. `husky.execute` parses config files and executes the user specified commands. `husky.execute` returns the same exit code as the command executed. 
If the command executed returns a successful exit code (`0`) then the git command wil also be executed, otherwise it will fail.

### Flow of Execution
1. On compile, Husky installs git-hook scripts
1. User invokes a git command (`git commit -m "my great commit"`)
1. A git-hook script is triggered (`.git/hooks/pre-commit`)
1. The git-hook script calls an escript (`priv/husky`)
1. The escript calls a mix task (`mix husky.execute`)
1. The mix task executes user-specified command from configs (`config :husky, pre_commit: "mix format"`)
1. The exit code of user-specified command is returned to git, which dictates if the git command will be executed

 
* **Build** - `rm priv/husky && MIX_ENV=prod mix escript.build`
* **Publish** - `mix hex.publish`
* **Install** 
    * install hook scripts in [sandbox](./sandbox) directory
    ```bash
    rm -rf dev/sandbox/.git/ && \               # clean up
        cd dev/sandbox && git init && cd - && \ # create git                          
        MIX_ENV=test mix husky.install && \     # install scripts
        cd - && git commit                      # run git commands
    ```
* **Delete** 
    * delete hook scripts from sandbox `MIX_ENV=test mix husky.delete`
* **Git Hooks** 
    * execute git hooks manually via mix task - `MIX_ENV=test mix husky.execute pre_commit`
    * execute git hooks manually via escript - `MIX_ENV=test ./priv/husky pre_commit`
        
### Helpful Resources
* [githooks documentation](https://git-scm.com/docs/githooks)