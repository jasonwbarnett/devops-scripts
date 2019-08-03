#!/bin/bash
# Author: Jason Barnett <J@sonBarnett.com>

function ask_question {
    local question

    question=$1
    read -r -p "$question: "
    echo "${REPLY}"
}

function ask_yes_no {
    local question answer

    question=$1
    read -r -p "$question: [y/n] "
    answer=$(echo "${REPLY}" | downcase)

    while [[ "${answer}" != "yes" && "${answer}" != "no" && "${answer}" != "y" && "${answer}" != "n" ]];do
        read -r -p "y/n only please... $question: [y/n] "
        answer=$(echo "${REPLY}" | downcase)
    done

    [[ "${answer}" == "yes" || "${answer}" == "y" ]] && echo true || echo false
}

function succ_or_fail {
    # shellcheck disable=SC2181
    if [[ $? == 0 ]]; then
        msg success!
    else
        err_msg failed!
    fi
}

function msg {
    echo "$1"
}

function err_msg {
    echo -e '\E[31m'"\033[1m${1}\033[0m" 1>&2
}

function fail_msg {
    err_msg "${1}"
    exit 1
}

function downcase {
  tr '[:upper:]' '[:lower:]'
}

function upcase {
  tr '[:lower:]' '[:upper:]'
}

function rstrip {
  sed 's/[[:space:]]*$//' -
}

function lstrip {
  sed 's/^[[:space:]]*//' -
}

function strip {
  lstrip | rstrip
}

function gsub {
  local pattern replacement

  pattern=$1
  replacement=$2

  if [[ -n $pattern ]] && [[ -n $replacement ]]; then
    sed "s|$pattern|$replacement|g"
  fi
}
