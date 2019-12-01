#!/usr/bin/env bash

# To redraw line after fzf closes (printf '\e[5n')
bind '"\e[0n": redraw-current-line'

_fzf_obc() {
  local fzf_obc_path
  fzf_obc_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )

  local lib
  while IFS= read -r -d '' lib;do
    [[ -e "${lib}" && ! -d "${lib}" ]] || continue
    # shellcheck source=/dev/null
    source "${lib}"
  done < <(find "${fzf_obc_path}/../lib/fzf-obc/" -type f \( -name '*.sh' -o -name '*.bash' \) -print0 2>/dev/null)

  complete -p fzf &> /dev/null || complete -F _longopt fzf

  __fzf_obc_load_user_functions
  __fzf_obc_update_complete
  __fzf_obc_add_all_traps

  return 0
}

_fzf_obc "$@"
