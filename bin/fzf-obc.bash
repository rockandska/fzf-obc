#!/usr/bin/env bash

# To redraw line after fzf closes (printf '\e[5n')
bind '"\e[0n": redraw-current-line'

_fzf_obc() {
  local fzf_obc_path
  fzf_obc_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )

  local lib
  for lib in "${fzf_obc_path}"/../lib/fzf-obc/*.{sh,bash};do
    [[ -e "${lib}" && ! -d "${lib}" ]] || continue
    # shellcheck source=/dev/null
    source "${lib}"
  done

  [[ -z "${1}" || "${1}" == "init" ]] && eval "$(__fzf_obc_get_env)"
  [[ -z "${1}" || "${1}" == "cleanup" ]] && __fzf_obc_cleanup

  complete -p fzf &> /dev/null || complete -F _longopt fzf

  [[ -z "${1}" || "${1}" == "load" ]] && __fzf_obc_load
  [[ -z "${1}" || "${1}" == "update" ]] && __fzf_obc_update_complete

  return 0
}

_fzf_obc "$@"
