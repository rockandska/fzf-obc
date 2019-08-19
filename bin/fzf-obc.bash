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

__fzf_obc_init_vars() {
  : "${FZF_OBC_PATH:=}"
  : "${FZF_OBC_HEIGHT:=40%}"
  : "${FZF_OBC_EXCLUDE_PATH:=.git:.svn}"
  : "${FZF_OBC_COLORS:=1}"
  : "${FZF_OBC_OPTS:=--select-1 --exit-0}"
  : "${FZF_OBC_BINDINGS:=--bind tab:accept}"
  : "${FZF_OBC_GLOBS_COLORS:=1}"
  : "${FZF_OBC_GLOBS_OPTS:=-m --select-1 --exit-0}"
  : "${FZF_OBC_GLOBS_BINDINGS:=}"

  : "${FZF_OBC_GLOBS_MAXDEPTH:=999999}"
}

###########################################################

# To redraw line after fzf closes (printf '\e[5n')
bind '"\e[0n": redraw-current-line'

__fzf_obc_add_trap() {
    local f="$1"
    shift
    local trap=${trap_prefix}${f}
    # Ensure that the function exist
    type -t "${f}" > /dev/null 2>&1 || return 1
    # Get the original definition
    local origin
    origin=$(declare -f "${f}" | tail -n +3 | head -n -1)
    # Quit if already surcharged
    [[ "${origin}" =~ ${trap} ]] && return 0
    # Add trap
    local add_trap='trap '"'"''${trap}' "$?" $@; trap - RETURN'"'"' RETURN'
    origin=$(echo "${origin}" | sed -r "/${trap}/d")
    eval "
      ${f}() {
        ${add_trap}
        ${origin}
      }
    "
}

__fzf_obc_cleanup() {
  [[ -z "${wrapper_prefix}" || -z "${trap_prefix}" ]] && 1>&2 echo '__fzf_cleanup : wrapper_prefix/trap_prefix variables not defined' && return 1
  local IFS=$'\n'
  # Revert back to the original complete definitions
  local existing_complete_arr
  read -r -d '' -a existing_complete_arr < <(
    complete | grep -o -- "-F ${wrapper_prefix}.*" | awk '{print $2}' | sort -u
  )
  local f
  for f in "${existing_complete_arr[@]}";do
    # Remove the wrapper to complete definition
    local new_complete_arr
    read -r -d '' -a new_complete_arr < <(
      complete | grep -E -- "-F ${f}( |$)" | sed -r "s/-F ${wrapper_prefix}/-F /;s/ +$//"
    )
    local w
    for w in "${new_complete_arr[@]}";do
      if echo "${w}" | awk '{ if(NF==3){exit 0}else{exit 1} }';then
        eval "${w} ''"
      else
        eval "${w}"
      fi
    done
  done
  # Unset existing fzf_obc functions
  local existing_wrappers_arr
  read -r -d '' -a existing_wrappers_arr < <(
    declare -F | grep -E -o -- "-f (${wrapper_prefix}|${post_prefix}).*" | awk '{print $2}' | sort -u
  )
  for f in "${existing_wrappers_arr[@]}";do
    unset -f "$f"
  done
  # Remove traps
  local existing_traps_arr
  read -r -d '' -a existing_traps_arr < <(
    declare -F | grep -E -o -- "-f ${trap_prefix}.*" | awk '{print $2}' | sort -u
  )
  for f in "${existing_traps_arr[@]}";do
    unset -f "$f"
    # Get the actual function definition
    f=${f/${trap_prefix}/}
    if type -t "${f}" > /dev/null 2>&1 ;then
      local origin
      read -r -d '' origin < <(
        declare -f "${f}" | tail -n +3 | head -n -1 | sed -r "/(${trap_prefix})/d"
      )
      eval "
        ${f}() {
          ${origin}
        }
      "
    fi
  done
}

__fzf_obc_load() {
  local IFS=$'\n'
  # Load functions / traps
  local fzf_obc_path
  fzf_obc_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" >/dev/null 2>&1 && pwd )/bash_completion.d"
  local fzf_obc_path_array path file
  IFS=':' read -r -a fzf_obc_path_array <<< "${FZF_OBC_PATH}"
  for path in "${fzf_obc_path}" "${fzf_obc_path_array[@]}";do
    for file in "${path}"/* ; do
      [[ -e "${file}" && ! -d "${file}" ]] || continue
      # shellcheck disable=SC1090
      source "${file}"
    done
  done
}

__fzf_obc_update_complete() {
  [[ -z "${wrapper_prefix}" || -z "${trap_prefix}" ]] && 1>&2 echo '__fzf_obc_update_complete : wrapper_prefix/trap_prefix variables not defined' && return 1
  local IFS=$'\n'
  # Get complete function not already wrapped
  local complete_loaded_functions_arr
  read -r -d '' -a complete_loaded_functions_arr < <(
    complete | grep -o -- '-F.*' | cut -d ' ' -f 2 | sort -u | grep -v "^${wrapper_prefix}"
  )
  # Loop over loaded function to create a wrapper to it
  local f
  for f in "${complete_loaded_functions_arr[@]}";do
    wrapper_name="${wrapper_prefix}${f}"
    wrapper_function='__fzf_obc_read_compreply'
    # Create the wrapper if not exist
    if ! type -t "${wrapper_name}" > /dev/null 2>&1 ; then
      eval "
        ${wrapper_name}() {
          local cur prev words cword split cpl_status;
          _init_completion -s || return;
          ${f} \$@ || cpl_status=\$?
          if type -t __fzf_obc_post_${f} > /dev/null 2>&1;then
            local wrapper_prefix='${wrapper_prefix}'
            local post_prefix='${post_prefix}'
            local trap_prefix='${trap_prefix}'
            __fzf_obc_post_${f} || return \$?
          fi
          ${wrapper_function}
          return \$cpl_status
        }
      "
    fi
    # Apply the wrapper to complete definition
    local new_complete
    read -r -d '' -a new_complete < <(
      complete | grep -E -- "-F ${f}( |$)" | sed -r "s/-F ${f}( |$)/-F ${wrapper_name}\1/;s/ +$//"
    )
    local w
    for w in "${new_complete[@]}";do
      if echo "${w}" | awk '{ if(NF==3){exit 0}else{exit 1} }';then
        eval "${w} ''"
      else
        eval "${w}"
      fi
    done
  done
  # Loop over existing trap and add them
  local loaded_traps_arr
  read -r -d '' -a loaded_traps_arr < <(
    declare -F | grep -E -o -- "-f ${trap_prefix}.*" | awk '{print $2}' | sort -u
  )
  local f
  for f in "${loaded_traps_arr[@]}";do
    f="${f/${trap_prefix}}"
    __fzf_obc_add_trap "$f"
  done
}

_fzf_obc() {
  local wrapper_prefix='__fzf_obc_wrapper_'
  local post_prefix='__fzf_obc_post_'
  local trap_prefix='__fzf_obc_trap_'
  complete -p fzf &> /dev/null || complete -F _longopt fzf
  [[ -z "${1}" || "${1}" == "cleanup" ]] && __fzf_obc_cleanup
  [[ -z "${1}" || "${1}" == "init" ]] && __fzf_obc_init_vars
  [[ -z "${1}" || "${1}" == "load" ]] && __fzf_obc_load
  [[ -z "${1}" || "${1}" == "update" ]] && __fzf_obc_update_complete
  return 0
}

_fzf_obc "$@"
