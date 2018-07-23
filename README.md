# Private NPM Buildkite Plugin [![Build status](https://badge.buildkite.com/705414e5df1533fbc18a2dda1305ec015282575a87edb1e0c1.svg)](https://buildkite.com/seek/private-npm-buildkite-plugin)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to allow pipeline steps to easily install
private packages from an [npm](https://www.npmjs.com) repository.

Note this plugin should work equally well despite any personal preferences for either `yarn` or `npm`.

## Example

To read the value from an environment variable named `MY_TOKEN` when the plugin executes, use the `env:` prefix.

```yml
steps:
  - command: yarn install
    plugins:
      seek-oss/private-npm#v1.1.1:
        token: "env:MY_TOKEN"
```

To read the value from a file named `my_token_file`, use the `file:` prefix.

```yml
steps:
  - command: yarn install
    plugins:
      seek-oss/private-npm#v1.1.1:
        token: "file:my_token_file"
```

Alternatively you can read the token directly from any value exposed toxs your `pipeline.yml` file.  However, this 
approach is discoraged in favour of using with the `env:` or `file:` prefix.  This functionality remains in the interest
 of backwards compatibility.

```yml
steps:
  - command: yarn install
    plugins:
      seek-oss/private-npm#v1.1.1:
        token: ${MY_TOKEN}
```


You can also specify a custom npm registry if you are using your own mirror.

```yml
steps:
  - command: yarn install
    plugins:
      seek-oss/private-npm#v1.1.1:
        token: ${MY_TOKEN}
        registry: //myprivatenpm.com/
```

## Configuration

### `token` (required)
The value of the NPM token.  Using the prefix `env:` of `file:` changes the behaviour of how the token is read.  By 
omitting the prefix, the value will be read from a variable which is available to the Buildkite YAML parsing context.  
This value is interpolated when the YAML configuration is parsed by the Buildgent agent and provided to the plugin "as 
is".

Using the `env:` prefix delays reading the value from the agent environment until the plugin executes.

Using the `file:` prefix will attempt to read the value from a file.

The prefix variants are recommended if you are using a secrets manager or some other kind of late variable binding 
mechanism to configure your agent's environment.  Please see the examples for useage.

Example: `${MY_TOKEN}`
> **NOTE:** Don't put your tokens into source control.  Don't use web interfaces you don't control to inject them into 
> your environment either.  Rather use a Secrets Manager.  If you are an AWS user, perhaps consider the 
> [aws-sm-buildkite-plugin](https://github.com/seek-oss/aws-sm-buildkite-plugin) which works well with this plugin.

> **NOTE:** There is anecdotal evidence to suggest that using `NPM_TOKEN` as the variable name containing the 
> token can intermittently cause the token to become empty.  It is advised to use a different name as has been done in 
> these docs.

### `registry` (optional)
The path to a private npm repository.  Please ensure you supply the trailing `/`!

Example: `//myprivatenpm.com/`

## License
MIT (see [LICENSE](./LICENSE))
