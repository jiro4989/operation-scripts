#!/bin/bash

this_script="$(basename "$0")"

usage() {
  cat << EOS
${this_script} prints configurations of ports of all firewall service.

Usage:
    ${this_script}
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

exists_ufw() {
  exists_command ufw
}

exists_iptables() {
  exists_command iptables
}

prints_ufw_status() {
  if ! exists_ufw; then
    return
  fi
  info "Prints configurations with ufw"
  sudo ufw status
}

prints_iptables_status() {
  if ! exists_ufw; then
    return
  fi
  info "Prints configurations with iptables"
  sudo iptables -L
}

if [[ 0 -lt $# ]] && [[ $1 = "-h" ]] || [[ $1 = "--help" ]]; then
  usage
  exit
fi

prints_ufw_status
prints_iptables_status

info "${this_script} was completed."
