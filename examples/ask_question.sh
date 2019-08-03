#!/bin/bash
. "$( dirname "${BASH_SOURCE[0]}" )/helper.sh"

answer=$(ask_question "What is your favorite color?")
echo "How wonderful! I love ${answer} too."
