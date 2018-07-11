# Private NPM Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to allow pipeline steps to easily install
private packages from an [npm](https://www.npmjs.com) repository.

Note this plugin should work equally well despite your personal preferences for either `yarn` or `npm`.

## Example

The following pipeline will run `yarn install` (and presumably some private packages).

```yml
steps:
  - command: yarn install
    plugins:
      seek-oss/private-npm:
        token: ${NPM_TOKEN}
```

You can also specify a custom npm registry if you are using your own mirror.

```yml
steps:
  - command: yarn install
    plugins:
      seek-oss/private-npm:
        token: ${NPM_TOKEN}
        registry: //myprivatenpm.com/
```

## Configuration
### `token` (required)
The value of the NPM token.  

> *NOTE* It's bad security practise to put your secrets into source control. A better idea is to use environment variables.

### `registry` (optional)
The path to a private npm repository.  Please ensure you supply the trailing `/`!

## License
MIT (see [LICENSE](./LICENSE))
