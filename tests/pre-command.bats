#!/usr/bin/env bats

load "$BATS_PATH/load.bash"
teardown() {
  rm -f .npmrc
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_ENV
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_TOKEN
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_FILE
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_REGISTRY
  unset MY_ENV_VAR
  rm -fr my_token_file
  rm -fr my_empty_file
}


@test "creates a npmrc file with default registry path and token" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_TOKEN='abc123'

  run $PWD/hooks/pre-command

  assert_success
  assert [ -e '.npmrc' ]
  assert_equal "$(head -n1 .npmrc)" '//registry.npmjs.org/:_authToken=abc123'
}

@test "reads the token from a file if the file parameter is used" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_FILE='my_token_file'
  echo 'abc123' > my_token_file

  run $PWD/hooks/pre-command

  assert_success
  assert [ -e '.npmrc' ]
  assert_equal "$(head -n1 .npmrc)" '//registry.npmjs.org/:_authToken=abc123' 
}

@test "fails if the file parameter is used but no file exists" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_FILE='my_missing_file'

  run $PWD/hooks/pre-command

  assert_failure
}

@test "fails if the file parameter is used and the file exists but is empty" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_FILE='my_empty_file'

  touch my_empty_file

  run $PWD/hooks/pre-command

  assert_failure
}

@test "reads the token from the environment if the env parameter is used" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_ENV='MY_ENV_VAR'
  export MY_ENV_VAR='abc123'

  run $PWD/hooks/pre-command

  assert_success
  assert [ -e '.npmrc' ]
  assert_equal "$(head -n1 .npmrc)" '//registry.npmjs.org/:_authToken=abc123'
}

@test "fails if the env parameter is used but no such variable is defined" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_ENV='MY_MISSING_VAR'

  run $PWD/hooks/pre-command

  assert_failure
}

@test "fails if the env parameter is used but the value of the variable is empty" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_ENV='MY_EMPTY_VAR'

  export MY_EMPTY_VAR=""

  run $PWD/hooks/pre-command

  assert_failure
}

@test "creates a npmrc file with supplied registry path and token" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_TOKEN='abc123'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_REGISTRY='//myprivateregistry.org/'

  run $PWD/hooks/pre-command

  assert_success
  assert [ -e '.npmrc' ]
  assert_equal "$(head -n1 .npmrc)" '//myprivateregistry.org/:_authToken=abc123'
}

@test "creates a npmrc file with supplied registry path and env" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_ENV='MY_ENV_VAR'
  export MY_ENV_VAR='abc123'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_REGISTRY='//myprivateregistry.org/'

  run $PWD/hooks/pre-command

  assert_success
  assert [ -e '.npmrc' ]
  assert_equal "$(head -n1 .npmrc)" '//myprivateregistry.org/:_authToken=abc123'
}

@test "creates a npmrc file with supplied registry path and file" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_FILE='my_token_file'
  echo 'abc123' > my_token_file
  export BUILDKITE_PLUGIN_PRIVATE_NPM_REGISTRY='//myprivateregistry.org/'

  run $PWD/hooks/pre-command

  assert_success
  assert [ -e '.npmrc' ]
  assert_equal "$(head -n1 .npmrc)" '//myprivateregistry.org/:_authToken=abc123'
}

@test "the command fails if none of the fields are not set" {
  run $PWD/hooks/pre-command

  assert_failure
  refute [ -e '.npmrc' ]
}

# There is an exclusive relationship between file, env, and token.  These tests ensure only value is set and fail with 
# a meaninful message otherwise
@test "fails if env and file are both set" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_FILE='my_token_file'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_ENV='MY_ENV_VAR'

  run $PWD/hooks/pre-command

  assert_failure
  assert_output ':no_entry_sign: :npm: :package: Failed! Only one of file, env or token parameters may be set'
  refute [ -e '.npmrc' ]
}

@test "fails if token and file are both set" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_FILE='my_token_file'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_TOKEN='abc123'

  run $PWD/hooks/pre-command

  assert_failure
  assert_output ':no_entry_sign: :npm: :package: Failed! Only one of file, env or token parameters may be set'
  refute [ -e '.npmrc' ]
}

@test "fails if env and token are both set" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_TOKEN='abc123'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_ENV='MY_ENV_VAR'

  run $PWD/hooks/pre-command

  assert_failure
  assert_output ':no_entry_sign: :npm: :package: Failed! Only one of file, env or token parameters may be set'
  refute [ -e '.npmrc' ]
}

@test "fails if env, file and token are all set" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_FILE='my_token_file'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_ENV='MY_ENV_VAR'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_TOKEN='abc123'

  run $PWD/hooks/pre-command

  assert_failure
  assert_output ':no_entry_sign: :npm: :package: Failed! Only one of file, env or token parameters may be set'
  refute [ -e '.npmrc' ]
}