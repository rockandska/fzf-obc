#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/-completion.bash
#
# - $FZF_OBC_PATH             (default: fzf-obc/bash_completion.d)
#
# - $FZF_OBC_HEIGHT           (default: 40%)
# - $FZF_OBC_EXCLUDE_PATH     (default: .git:.svn)
# - $FZF_OBC_OPTS             (default: --select-1 --exit-0)
# - $FZF_OBC_BINDINGS         (default: --bind tab:accept)
#
# **** Only when using globs pattern ****
# - $FZF_OBC_GLOBS_MAXDEPTH   (default: 999999)
# - $FZF_OBC_GLOBS_OPTS       (default: -m --select-1 --exit-0)
# - $FZF_OBC_GLOBS_BINDINGS   (default: )

__fzf_obc_init_vars() {
  : "${FZF_OBC_PATH:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/bash_completion.d}"
  : "${FZF_OBC_HEIGHT:=40%}"
  : "${FZF_OBC_EXCLUDE_PATH:=.git:.svn}"
  : "${FZF_OBC_OPTS:=--select-1 --exit-0}"
  : "${FZF_OBC_BINDINGS:=--bind tab:accept}"
  : "${FZF_OBC_GLOBS_OPTS:=-m --select-1 --exit-0}"
  : "${FZF_OBC_GLOBS_BINDINGS:=}"

  : "${FZF_OBC_GLOBS_MAXDEPTH:=999999}"
}

###########################################################

# get find exclude pattern
_fzf_obc_globs_exclude() {
  local var=$1
  local sep str fzf_obc_globs_exclude_array
  IFS=':' read -r -a fzf_obc_globs_exclude_array <<< "${FZF_OBC_EXCLUDE_PATH}"
  if [[ ${#fzf_obc_globs_exclude_array[@]} -ne 0 ]];then
    str="\( -path '*/${fzf_obc_globs_exclude_array[0]%/}"
    for pattern in "${fzf_obc_globs_exclude_array[@]:1}";do
      __expand_tilde_by_ref pattern
      if [[ "${pattern}" =~ ^/ ]];then
        sep="' -o -path '"
      else
        sep="' -o -path '*/"
      fi
      pattern=${pattern%\/}
      str+=$(printf "%s" "${pattern/#/$sep}")
    done
    str+="' \) -prune -o"
  fi
  eval "${var}=\"${str}\""
}


# To use custom commands instead of find, override _fzf_compgen_{path,dir} later
_fzf_obc_search() {
  local type xspec
  type="${1}"
  shift
  xspec=${1:+"*.@($1|${1^^})"}

  local cur_expanded=${cur:-./}
  __expand_tilde_by_ref cur_expanded

  local startdir
  if [[ -n "${cur_expanded}" ]] && [[ ! "${cur_expanded}" =~ (\.\.?|/)$ ]];then
    startdir="${cur_expanded}*"
  else
    startdir="${cur_expanded}"
  fi

  local opt_str
  _fzf_obc_globs_exclude opt_str
  cmd="command find -L $startdir -mindepth 1 -maxdepth '${FZF_OBC_GLOBS_MAXDEPTH}'"

  case ${type} in
    paths)
      cmd+=" ${opt_str} \( -type d -printf '%p/\n' -or -print \) 2> /dev/null"
      ;;
    files)
      cmd+=" \( -type f -or -type l \)"
      ;;
    dirs)
      cmd+=" -type d -print 2> /dev/null "
      ;;
  esac

  if [[ "${type}" == "files" ]] && [[ -n ${xspec} ]];then
    cmd+=" -exec bash -c 'shopt -s extglob; for file;do [[ \"\$file\" == ${xspec} ]] && echo \"\${file/${cur_expanded//\//\\/}/${cur//\//\\/}}\";done' internalsh {} + 2> /dev/null"
  else
    cmd+=" | sed 's/${cur_expanded//\//\\/}/${cur//\//\\/}/'"
  fi
  eval "${cmd}"

}

###########################################################

# To redraw line after fzf closes (printf '\e[5n')
bind '"\e[0n": redraw-current-line'

__fzf_obc_cmd() {
    fzf $@
}

__fzf_obc_load() {
  local fzf_obc_path_array path file
  IFS=':' read -r -a fzf_obc_path_array <<< "${FZF_OBC_PATH}"
  for path in "${fzf_obc_path_array[@]}";do
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
    if [[ "${f}" != "_completion_loader" ]];then
      __fzf_obc_add_trap $f
    fi
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
  local f='_completion_loader'
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

    if [[ "${cur}" == *"**" ]];then
      if [[ "${#COMPREPLY[@]}" -ne 0 ]];then
        local item
        compopt +o filenames
        IFS=$'\n' read -r -a COMPREPLY <<<$(
          printf "%s\n" "${COMPREPLY[@]}" \
          | awk '! a[$0]++' \
          | FZF_DEFAULT_OPTS="--height ${FZF_OBC_HEIGHT} --reverse ${FZF_OBC_GLOBS_OPTS} ${FZF_OBC_GLOBS_BINDINGS}" \
            __fzf_obc_cmd \
          | while read -r item;do [[ -n "${item}" ]] && printf "%q " "${item}" | sed 's/^\\~/~/';done \
          | sed 's/ $//'
        )
      else
          compopt -o nospace
          COMPREPLY=( "${cur%\*\*}" )
      fi
    else
      IFS=$'\n' read -r -a COMPREPLY <<<$(
        printf "%s\n" "${COMPREPLY[@]}" \
        | awk '! a[$0]++' \
        | FZF_DEFAULT_OPTS="--height ${FZF_OBC_HEIGHT} --reverse ${FZF_OBC_OPTS} ${FZF_OBC_BINDINGS}" \
          __fzf_obc_cmd
      )
    fi
    printf '\e[5n'
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
