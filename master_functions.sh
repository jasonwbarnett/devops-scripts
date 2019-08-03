#!/bin/bash
# Author: Jason Barnett <J@sonBarnett.com>

############
## README ##
############
##
##  This is a compilation of useful functions in everyday sysadmin life.
##
###########


## Functions ##
###############

function ask_question {
    question=$1
    read -p "$question: "
    echo $REPLY
}

function ask_yes_no {
    question=$1
    read -p "$question: [y/n] "
    local answer=$(echo $REPLY | downcase)

    while [[ "${answer}" != "yes" && "${answer}" != "no" && "${answer}" != "y" && "${answer}" != "n" ]];do
        read -p "y/n only please... $question: [y/n] "
        answer=$(echo $REPLY | downcase)
    done

    [[ "${answer}" == "yes" || "${answer}" == "y" ]] && echo true || echo false
}

function succ_or_fail {
    [[ $? == 0 ]] && msg success! || msg failed!
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
  local pattern=$1
  local replacement=$2

  if [[ -n $pattern ]] && [[ -n $replacement ]]; then
    sed "s|$pattern|$replacement|g"
  fi
}
