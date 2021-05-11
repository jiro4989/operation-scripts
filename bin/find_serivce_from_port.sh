#!/bin/bash

this_script="$(basename "$0")"

usage() {
  cat << EOS
${this_script} finds the management service that a process is using any port.

Usage:
    ${this_script} <port>
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

exists_service() {
  exists_command service
}

exists_systemctl() {
  exists_command systemctl
}

exists_supervisorctl() {
  exists_command supervisorctl
}

find_service_by_service() {
  if ! exists_service; then
    return
  fi

  local svc="$1"
  info "Search ${svc} from service."
  service --status-all | grep -E "${svc}"
}

find_service_by_systemd() {
  if ! exists_systemctl; then
    return
  fi

  local svc="$1"
  info "Search ${svc} from systemd."
  systemctl list-unit-files | grep -E "${svc}"
}

find_service_by_supervisord() {
  if ! exists_supervisorctl; then
    return
  fi

  local svc="$1"
  info "Search ${svc} from supervisord."
  supervisorctl status | grep -E "${svc}"
}

search_service() {
  local port="$1"
  sudo lsof -i ":${port}"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

if [[ $1 = "-h" ]] || [[ $1 = "--help" ]]; then
  usage
  exit
fi

port="$1"

info "Search service that using port (${port}) with lsof."
search_service "${port}"

count="$(search_service "${port}" | wc -l)"
if [[ "$count" -lt 1 ]]; then
  info "Not found the service that using port (${port})."
  exit
fi

info "Search management service with command name."
search_service "${port}" | awk '1<NR{print $1}' | sort | uniq | while read -r cmd; do
  find_service_by_service "$cmd"
  find_service_by_systemd "$cmd"
  find_service_by_supervisord "$cmd"
done

info "${this_script} was finished."
