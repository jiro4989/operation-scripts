#!/bin/bash

this_script="$(basename "$0")"

usage() {
  cat << EOS
${this_script} downloads file with available command.

Usage:
    ${this_script} <url> <dest_path>
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

download_with_curl() {
  local url="$1"
  local dst="$2"
  info "Downloads file from $url to $dst with curl."
  curl -o "${dst}" -sSL "${url}"
}

download_with_wget() {
  local url="$1"
  local dst="$2"
  info "Downloads file from $url to $dst with wget."
  wget -O "${dst}" "${url}"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

if [[ $1 = "-h" ]] || [[ $1 = "--help" ]]; then
  usage
  exit
fi

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

url="$1"
dst="$2"

if exists_command curl; then
  download_with_curl "${url}" "${dst}" || exit 1
elif exists_command wget; then
  download_with_wget "${url}" "${dst}" || exit 1
else
  info "Not found available commands."
  exit 1
fi

info "${this_script} was completed."
