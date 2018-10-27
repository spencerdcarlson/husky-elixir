## Development

## High Level Design
The [husky.install](../lib/install.ex) mix task will generate a and install a default bash script in the `.git/hooks` directory
for every possible git hook (see `:hook_list` in [config/config.exs](../config/config.exs)) These husky hook scripts will invoke the [escript](../lib/escript.ex) that gets packaged in `priv/husky`. 
The escript invokes the [husky.execute](../lib/execute.ex) mix task. `husky.execute` parses config files and executes the user specified commands. `husky.execute` returns the same exit code as the command executed. 
If the command executed returns a successful exit code (`0`) then the git command wil also be executed, otherwise it will fail. 




* **Build** - `rm priv/husky && MIX_ENV=prod mix escript.build`
* **Publish** - `mix hex.publish`
* **Install** 
    * install hook scripts in sandbox `cd dev/sandbox && git init && cd ../../ && MIX_ENV=test mix husky.install`
* **Delete** 
    * delete hook scripts from sandbox `MIX_ENV=test mix husky.delete`
* **Git Hooks** 
    * execute git hooks manually via mix task - `MIX_ENV=test mix husky.execute pre_commit`
    * execute git hooks manually via escript - `MIX_ENV=test ./priv/husky pre_commit`
    * execute from git in sandbox - `cd dev/sandbox/.git/hooks && ./pre-commit`
        * *Note: The mix task `husky.execute` will not be available from there*