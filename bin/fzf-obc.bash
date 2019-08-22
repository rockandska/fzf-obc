#!/usr/bin/env bash
#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/-completion.bash
#
# - $FZF_OBC_PATH               (default: )
# - $FZF_OBC_COLORS             (default: 1)
# - $FZF_OBC_HEIGHT             (default: 40%)
# - $FZF_OBC_EXCLUDE_PATH       (default: .git:.svn)
# - $FZF_OBC_OPTS               (default: --select-1 --exit-0)
# - $FZF_OBC_BINDINGS           (default: --bind tab:accept)
#
# **** Only when using globs pattern ****
# - $FZF_OBC_GLOBS_OPTS         (default: -m --select-1 --exit-0)
# - $FZF_OBC_GLOBS_BINDINGS     (default: )
# - $FZF_OBC_GLOBS_MAXDEPTH     (default: 999999)

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
