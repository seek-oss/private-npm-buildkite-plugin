#!/usr/bin/env bats

load "$BATS_PATH/load.bash"
teardown() {
  rm -f .npmrc
  rm -f ./tests/path/to/project/.npmrc
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_ENV
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_TOKEN
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_FILE
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_REGISTRY
  unset MY_ENV_VAR
  unset MY_ENV_VAR1
  unset MY_ENV_VAR2
  unset MY_ENV_VAR3
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_0_ENV
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_0_PATH
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_1_ENV
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_1_PATH
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_2_ENV
  unset BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_2_PATH
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

@test "creates a npmrc file with supplied output path and token" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_TOKEN='abc123'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_OUTPUT_PATH='./tests/path/to/project/'

  run $PWD/hooks/pre-command

  assert_success
  assert [ -e './tests/path/to/project/.npmrc' ]
  assert_equal "$(head -n1 ./tests/path/to/project/.npmrc)" '//registry.npmjs.org/:_authToken=abc123'
}

@test  "creates a npmrc file when multi-registries are supplied' {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_OUTPUT_PATH='./tests/path/to/project/'

  export MY_ENV_VAR1='abc123'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_0_ENV='MY_ENV_VAR1'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_0_PATH='//myprivateregistry1.org/'

  export MY_ENV_VAR2='def123'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_1_ENV='MY_ENV_VAR2'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_1_PATH='//myprivateregistry2.org/'

  export MY_ENV_VAR3='ghi123'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_2_ENV='MY_ENV_VAR3'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_2_PATH='//myprivateregistry3.org/'

  run $PWD/hooks/pre-command
  
  assert_success
  assert [ -e './tests/path/to/project/.npmrc' ]
  assert_equal "$(head -n 1 ./tests/path/to/project/.npmrc)" '//myprivateregistry1.org/:_authToken=abc123'
  assert_equal "$(head -n 2 ./tests/path/to/project/.npmrc | tail -n 1)" '//myprivateregistry2.org/:_authToken=def123'
  assert_equal "$(head -n 3 ./tests/path/to/project/.npmrc | tail -n 1)" '//myprivateregistry3.org/:_authToken=ghi123'
  assert_equal "$(head -n 4 ./tests/path/to/project/.npmrc | tail -n 1)" 'save-exact=true'
}

@test "the command fails if none of the fields are not set" {
  run $PWD/hooks/pre-command

  assert_failure
  refute [ -e '.npmrc' ]
}

# There is an exclusive relationship between file, env, token, and multi-registries. These tests ensure only value is set and fail with 
# a meaningful message otherwise
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

@test "fails if both multi-registries and env are set" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_ENV='MY_ENV_VAR'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_0_ENV='MY_ENV_VAR'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_0_PATH='/myprivateregistry.org//'

  run $PWD/hooks/pre-command

  assert_failure
  assert_output ':no_entry_sign: :npm: :package: Failed! When multi-registries are provided, the following fields cannot be set: env, file, token'
  refute [ -e '.npmrc' ]
}

@test "fails if both multi-registries and file are set" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_FILE='my_token_file'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_0_ENV='MY_ENV_VAR'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_0_PATH='/myprivateregistry.org//'

  run $PWD/hooks/pre-command

  assert_failure
  assert_output ':no_entry_sign: :npm: :package: Failed! When multi-registries are provided, the following fields cannot be set: env, file, token'
  refute [ -e '.npmrc' ]
}

@test "fails if both multi-registries and token are set" {
  export BUILDKITE_PLUGIN_PRIVATE_NPM_TOKEN='abc123'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_0_ENV='MY_ENV_VAR'
  export BUILDKITE_PLUGIN_PRIVATE_NPM_MULTI_REGISTRIES_0_PATH='/myprivateregistry.org//'

  run $PWD/hooks/pre-command

  assert_failure
  assert_output ':no_entry_sign: :npm: :package: Failed! When multi-registries are provided, the following fields cannot be set: env, file, token'
  refute [ -e '.npmrc' ]
}