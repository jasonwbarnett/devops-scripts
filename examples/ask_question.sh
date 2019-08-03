#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}/helper.sh"

answer=$(ask_question "What is your favorite color?")
echo "How wonderful! I love ${answer} too."
