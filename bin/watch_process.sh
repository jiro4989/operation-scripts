#!/bin/bash

set -eu

this_script="$(basename "$0")"
wait_interval_second=1

usage() {
  cat << EOS
${this_script} watches the process.

Usage:
    ${this_script} <process_name>
    ${this_script} -h | --help

Options:
    -h, --help    Prints this help
EOS
}

info() {
  cat << EOS

##
## $*
##

EOS
}

exists_command() {
  local cmd="$1"
  type "$cmd" > /dev/null 2>&1
}

exists_watch() {
  exists_command watch
}

watch_with_watch() {
  local process_name="$1"
  info "Watches ${process_name} with 'watch'."
  watch "${process_name}" -n "${wait_interval_second}"
}

watch_with_self() {
  local process_name="$1"
  info "Watches ${process_name} with self."
  while true; do
    ps aux | head -n 1
    ps aux | awk '1<NR{print $0}' | grep -F "${process_name}"
    sleep "${wait_interval_second}"
    clear
  done
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

if [[ $1 = "-h" ]] || [[ $1 = "--help" ]]; then
  usage
  exit
fi

process_name="$1"

trap 'info "${this_script} was completed."' SIGINT

if exists_watch; then
  watch_with_watch "${process_name}"
else
  watch_with_self "${process_name}"
fi
