#!/usr/bin/env bats

load "$BATS_PATH/load.bash"
teardown() {
  rm -f .npmrc
}


@test "creates a npmrc file with default registry path and token" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_TOKEN='abc123'

  run $PWD/hooks/pre-command

  assert_success
  assert [ -e '.npmrc' ]
  assert_equal "$(head -n1 .npmrc)" '//registry.npmjs.org/:_authToken=abc123'
}

@test "crates a npmrc file with supplied registry path and token" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_TOKEN='abc123'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_REGISTRY='//myprivateregistry.org/'

  run $PWD/hooks/pre-command

  assert_success
  assert [ -e '.npmrc' ]
  assert_equal "$(head -n1 .npmrc)" '//myprivateregistry.org/:_authToken=abc123'
}

@test "the command fails if the token is not set" {
  run $PWD/hooks/pre-command

  assert_failure
  refute [ -e '.npmrc' ]
}