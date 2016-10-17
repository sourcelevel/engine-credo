# engine-credo

`engine-credo` is a Docker container that wraps
[credo](http://github.com/rrrene/credo) as a standalone executable,
following the [Code Climate Engine spec](https://github.com/codeclimate/spec)
for JSON output.

`engine-credo` is available on [Ebert](https://ebertapp.io) as the default engine
for reviewing Elixir code.

## Configuration

`engine-credo` will respect the `.credo.exs` configuration placed inside your
repository. For more details, see the [`Configuration`](https://github.com/rrrene/credo#configuration)
section of Credo's README.

## Need help?

For help with `credo`,
[check out their documentation](https://github.com/rrrene/credo).
