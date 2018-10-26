## Development

## Build
`rm priv/husky && MIX_ENV=prod mix escript.build`

## Publish
`MIX_ENV=prod mix hex.publish`

## Install
* install hook scripts in sandbox
`MIX_ENV=test mix husky.install`

## Delete
* delete hook scripts from sandbox
`MIX_ENV=test mix husky.delete`