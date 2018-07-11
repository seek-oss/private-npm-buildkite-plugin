# Private NPM Buildkite Plugin [![Build status](https://badge.buildkite.com/705414e5df1533fbc18a2dda1305ec015282575a87edb1e0c1.svg)](https://buildkite.com/seek/private-npm-buildkite-plugin)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to allow pipeline steps to easily install
private packages from an [npm](https://www.npmjs.com) repository.

Note this plugin should work equally well despite your personal preferences for either `yarn` or `npm`.

## Example

The following pipeline will run `yarn install` (and presumably some private packages).

```yml
steps:
  - command: yarn install
    plugins:
      seek-oss/private-npm#v1.0.0:
        token: ${NPM_TOKEN}
```

You can also specify a custom npm registry if you are using your own mirror.

```yml
steps:
  - command: yarn install
    plugins:
      seek-oss/private-npm#v1.0.0:
        token: ${NPM_TOKEN}
        registry: //myprivatenpm.com/
```

## Configuration

### `token` (required)
The value of the NPM token.  

Example: `${NPM_TOKEN}`

> *NOTE* It's bad security practise to put your secrets into source control. A better idea is to use environment variables.

### `registry` (optional)
The path to a private npm repository.  Please ensure you supply the trailing `/`!

Example: `//myprivatenpm.com/`

## License
MIT (see [LICENSE](./LICENSE))
