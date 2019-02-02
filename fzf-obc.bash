#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/-completion.bash
#
# - $FZF_OBC_PATH              (default: fzf-obc/bash_completion.d)
#
# - $FZF_OBC_TMUX             (default: 0)
# - $FZF_OBC_TMUX_HEIGHT      (default: '40%')
# - $FZF_OBC_OPTS             (default: --select-1 --exit-0)
# - $FZF_OBC_GLOBS_OPTS       (default: -m --select-1 --exit-0)
# - $FZF_OBC_BINDINGS         (default: --bind tab:accept)
# - $FZF_OBC_GLOBS_BINDINGS   (default: )
# - $LINES                    (default: '40')
#
# **** Only when using globs pattern ****
# - $FZF_OBC_MAXDEPTH         (default: 999999999)

__fzf_obc_init_vars() {
  : "${FZF_OBC_PATH:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/bash_completion.d}"
  IFS=':' read -r -a FZF_OBC_PATH_ARRAY <<< "${FZF_OBC_PATH}"

  : "${FZF_OBC_TMUX:=0}"
  : "${FZF_OBC_TMUX_HEIGHT:='40%'}"
  : "${FZF_OBC_OPTS:=--select-1 --exit-0}"
  : "${FZF_OBC_GLOBS_OPTS:=-m --select-1 --exit-0}"
  : "${FZF_OBC_BINDINGS:=--bind tab:accept}"
  : "${FZF_OBC_GLOBS_BINDINGS:=}"
  : "${LINES:=40}"

  : "${FZF_OBC_GLOBS_MAXDEPTH:=10}"
}

###########################################################

# To use custom commands instead of find, override _fzf_compgen_{path,dir} later
  _fzf_obc_files() {
    command find -L "$1" -maxdepth "${FZF_OBC_GLOBS_MAXDEPTH}" \
      -name .git -prune -o -name .svn -prune -o \( -type f -o -type l \) \
      -a -not -path "$1" -print 2> /dev/null
  }

  _fzf_obc_dirs() {
    command find -L "$1" -maxdepth "${FZF_OBC_GLOBS_MAXDEPTH}" \
      -name .git -prune -o -name .svn -prune -o -type d \
      -a -not -path "$1" -printf "%p/\n" 2> /dev/null
  }

###########################################################

# To redraw line after fzf closes (printf '\e[5n')
bind '"\e[0n": redraw-current-line'

__fzf_obc_cmd() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_OBC_TMUX}" != 0 ] && [ ${LINES} -gt 15 ] &&
    fzf-tmux -d${FZF_OBC_TMUX_HEIGHT} $@ || fzf $@
}

__fzf_obc_load() {
  local path file
  for path in "${FZF_OBC_PATH_ARRAY[@]}";do
    for file in ${path}/* ; do
      [ -e "${file}" -a ! -d "${file}" ] || continue
      source "${file}"
    done
  done
}

__fzf_obc_add_traps() {
  # Get existing complete functions
  local loaded_array f loaded_functions
  loaded_functions=$(complete | grep -o -- '-F.*' | awk '{$NF >= 2}{print}' | cut -d ' ' -f 2 | sort -u)
  IFS=$'\n' read -r -a loaded_array -d '' <<< "${loaded_functions}"
  # Loop over existing loaded function to add an fzf trap
  for f in "${loaded_array[@]}";do
    __fzf_obc_add_trap $f
  done
}

__fzf_obc_add_trap() {
    local f="$1"
    shift
    # Ensure that the function exist
    type -t "${f}" 2>&1 > /dev/null || return 1
    # Get the original definition
    local origin=$(declare -f "${f}" | tail -n +3 | head -n -1)
    # Default trap
    local trap='__fzf_obc_default_trap'
    # If a specific trap exist, use it
    if type -t "__fzf_obc_trap${f}" 2>&1 > /dev/null;then
      trap='__fzf_obc_trap'${f}
    fi
    # Quit if already surcharged with the same trap
    [[ "${origin}" =~ ${trap} ]] && return
    # Reset fzf-obc params if trap changed
    origin=$(echo "${origin}" | sed -r "/(__fzf_obc_default_trap|__fzf_obc_trap${f}|fzf_original_args)/d")
    local add_trap='trap '"'"''${trap}' "$?" "${fzf_original_args}"; trap - RETURN'"'"' RETURN'
    # Add trap function
    eval "
      ${f}() {
        local fzf_original_args=\"\$@\"
        ${add_trap}
        ${origin}
      }
    "
}

__fzf_obc_add_dynamic_trap() {
  local f='__load_completion'
  # Ensure that the function exist
  type -t "${f}" 2>&1 > /dev/null || return 1
  # Get the original definition
  local origin=$(declare -f "${f}" | tail -n +3 | head -n -1)
  # Quit if already surcharged
  [[ "${origin}" =~ "__fzf_obc_add_traps" ]] && return 0
  local add_trap
  # Retry to surcharged traps
  local trap='__fzf_obc_add_traps'
  add_trap='trap '"'"''${trap}' "$?"; trap - RETURN'"'"' RETURN'
  # Enable the surcharged function
  eval "
    ${f}() {
      ${add_trap}
      ${origin}
    }
  "
}

__fzf_obc_default_trap() {
  local status=$1

  if [[ ${#COMPREPLY[@]} -ne 0 ]];then
    if [[ "${cur}" == *"/**" ]];then
      local item
      compopt +o filenames
      IFS=$'\n' read -r -a COMPREPLY <<<$(
        printf "%s\n" "${COMPREPLY[@]}" \
        | awk '! a[$0]++' \
        | FZF_DEFAULT_OPTS="--height ${FZF_OBC_TMUX_HEIGHT} --reverse ${FZF_OBC_GLOBS_OPTS} ${FZF_OBC_GLOBS_BINDINGS}" \
          __fzf_obc_cmd \
        | while read -r item;do printf "%q " "${item}";done \
        | sed 's/ $//'
      )
    else
      IFS=$'\n' read -r -a COMPREPLY <<<$(
        printf "%s\n" "${COMPREPLY[@]}" \
        | awk '! a[$0]++' \
        | FZF_DEFAULT_OPTS="--height ${FZF_OBC_TMUX_HEIGHT} --reverse ${FZF_OBC_OPTS} ${FZF_OBC_BINDINGS}" \
          __fzf_obc_cmd
      )
    fi
    printf '\e[5n'
  fi
  return ${status}
}

_fzf_complete() {
  __fzf_obc_init_vars
  __fzf_obc_load
  __fzf_obc_add_traps
  __fzf_obc_add_dynamic_trap
}

_fzf_complete

complete -F _longopt fzf
