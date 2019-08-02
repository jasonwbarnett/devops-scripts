#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}/helper.sh"

answer=$(ask_yes_no "Are you going to work today?")
if [[ $answer == true ]]; then
  echo "How sad :( -- try and make the best of it"
else
  echo "How wonderful! Have a great day off."
fi
