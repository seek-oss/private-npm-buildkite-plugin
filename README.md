# Private NPM Buildkite Plugin

[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fseek-oss%2Fprivate-npm-buildkite-plugin%2Fbadge&style=flat)](https://actions-badge.atrox.dev/seek-oss/private-npm-buildkite-plugin/goto)
[![GitHub Release](https://img.shields.io/github/release/seek-oss/private-npm-buildkite-plugin.svg)](https://github.com/seek-oss/private-npm-buildkite-plugin/releases)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to allow pipeline steps to easily install
private packages from an [npm](https://www.npmjs.com) repository.

Note this plugin should work equally well despite any personal preferences for either `yarn` or `npm`.

## Example

To read the value from an environment variable named `MY_TOKEN` when the plugin executes, use the `env` fiels.

```yml
steps:
  - command: yarn install
    plugins:
      - seek-oss/private-npm#v1.2.0:
          env: "MY_TOKEN"
```

To read the value from a file named `my_token_file`, use the `file` field.

```yml
steps:
  - command: yarn install
    plugins:
      - seek-oss/private-npm#v1.2.0:
          file: "my_token_file"
```

Alternatively you can read the token directly from any value exposed to your `pipeline.yml` file. However, this
approach is discouraged in favour of using with the `env` or `file` fields. This functionality remains in the interest
of backwards compatibility.

```yml
steps:
  - command: yarn install
    plugins:
      - seek-oss/private-npm#v1.2.0:
          token: ${MY_TOKEN}
```

You can also specify a custom npm registry if you are using your own mirror.

```yml
steps:
  - command: yarn install
    plugins:
      - seek-oss/private-npm#v1.2.0:
          env: "MY_TOKEN"
          registry: //myprivatenpm.com/
```

If you set a registry, you can configure a specific scope to fetch packages from your custom registry

```yml
steps:
  - command: yarn install
    plugins:
      - seek-oss/private-npm#v1.2.0:
          env: "MY_TOKEN"
          registry: //myprivatenpm.com/
          scope: "@myprivatescope"
```

## Configuration

> **NOTE** Even thought `env`, `file` and `token` are described as optional, _at least one must be set_ or the plugin
> will fail.

### `env` (optional)

The value of the NPM token will be read from the agent environment when the plugin executes. This is useful in working
around cases where eager binding of variables in `pipeline.yml` means some variables are not present in the
environment when the configuration file is parsed.

> **NOTE** : Beware of using `NPM_TOKEN` as the name for the environment variable. When using that name the variable
> is unstable and has a tedency to return an empty string in the context of this plugin.

### `file` (optional)

The value of the NPM token will be read from a file on the agent when the plugin executes. This is useful when working
with secret that are created as files on the filesystem when a build is initiated.

### `token` (optional)

The value of the NPM token will be read from a variable which is available to the Buildkite YAML parsing context.
This value is interpolated when the YAML configuration is parsed by the Buildgent agent and provided to the plugin "as
is".

Example: `${MY_TOKEN}`

> **NOTE:** Don't put your tokens into source control. Don't use web interfaces you don't control to inject them into
> your environment either. Rather use a Secrets Manager. If you are an AWS user, perhaps consider the
> [aws-sm-buildkite-plugin](https://github.com/seek-oss/aws-sm-buildkite-plugin) which works well with this plugin.

> **NOTE:** There is anecdotal evidence to suggest that using `NPM_TOKEN` as the variable name containing the
> token can intermittently cause the token to become empty. It is advised to use a different name as has been done in
> these docs.

### `registry` (optional)

The path to a private npm repository. Please ensure you supply the trailing `/`!

Example: `//myprivatenpm.com/`

### `output-path` (optional)

The path to the .npmrc that will be created. Please ensure you supply the trailing `/`!

Example: `./project/path/`

## License

MIT (see [LICENSE](./LICENSE))
