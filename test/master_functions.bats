#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../master_functions.sh"
}

@test "downcase" {
  result="$(echo 'HELLO' | downcase)"
  [ "$result" = "hello" ]
}

@test "upcase" {
  result="$(echo 'hello' | upcase)"
  [ "$result" = "HELLO" ]
}

@test "rstrip" {
  result="$(echo -e 'this  \nhas  \n a lot \n of whitespace  ' | rstrip)"
  IFS=$'\n' lines=($result)
  [ "${lines[0]}" = "this" ]
  [ "${lines[1]}" = "has" ]
  [ "${lines[2]}" = " a lot" ]
  [ "${lines[3]}" = " of whitespace" ]
}

@test "lstrip" {
  result="$(echo -e 'this  \nhas  \n a lot \n of whitespace  ' | lstrip)"
  IFS=$'\n' lines=($result)
  [ "${lines[0]}" = "this  " ]
  [ "${lines[1]}" = "has  " ]
  [ "${lines[2]}" = "a lot " ]
  [ "${lines[3]}" = "of whitespace  " ]
}

@test "strip" {
  result="$(echo -e 'this  \nhas  \n a lot \n of whitespace  ' | strip)"
  IFS=$'\n' lines=($result)
  [ "${lines[0]}" = "this" ]
  [ "${lines[1]}" = "has" ]
  [ "${lines[2]}" = "a lot" ]
  [ "${lines[3]}" = "of whitespace" ]
}
