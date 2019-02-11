#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/-completion.bash
#
# - $FZF_OBC_PATH               (default: )
#
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
  : "${FZF_OBC_OPTS:=--select-1 --exit-0}"
  : "${FZF_OBC_BINDINGS:=--bind tab:accept}"
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
    type -t "${f}" 2>&1 > /dev/null || return 1
    # Get the original definition
    local origin=$(declare -f "${f}" | tail -n +3 | head -n -1)
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
  # Revert back to the original complete definitions
  local existing_complete_arr=($(complete | grep -o -- "-F ${wrapper_prefix}*" | awk '{print $2}' | sort -u))
  local f
  for f in "${existing_complete_arr[@]}";do
    # Remove the wrapper to complete definition
    local new_complete=($(complete | grep -E -- "-F ${f}( |$)" | sed -r "s/-F ${wrapper_prefix}/-F /;s/ $//"))
    local w
    for w in "${new_complete[@]}";do
      if [[ "${w}" != "complete -F ${wrapper_name}" ]];then
        eval "${w}"
      fi
    done
  done
  # Unset existing fzf_obc functions
  local existing_wrappers_arr=($(declare -F | grep -E -o -- "-f (${wrapper_prefix}|${post_prefix}).*" | awk '{print $2}' | sort -u))
  for f in "${existing_wrappers_traps_arr[@]}";do
    unset -f $f
  done
  # Remove traps
  local existing_traps_arr=($(declare -F | grep -E -o -- "-f ${trap_prefix}.*" | awk '{print $2}' | sort -u))
  for f in "${existing_traps_arr[@]}";do
    unset -f $f
    # Get the actual function definition
    f=${f/${trap_prefix}/}
    if type -t "${f}" 2>&1 > /dev/null;then
      local origin=$(declare -f "${f}" | tail -n +3 | head -n -1)
      # Remove also the trap from the orgiinal function
      origin=$(echo "${origin}" | sed -r "/(${trap_prefix})/d")
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
  local fzf_obc_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/bash_completion.d"
  local fzf_obc_path_array path file
  IFS=':' read -r -a fzf_obc_path_array <<< "${FZF_OBC_PATH}"
  for path in "${fzf_obc_path}" "${fzf_obc_path_array[@]}";do
    for file in ${path}/* ; do
      [ -e "${file}" -a ! -d "${file}" ] || continue
      source "${file}"
    done
  done
}

__fzf_obc_update_complete() {
  local IFS=$'\n'
  [[ -z "${wrapper_prefix}" ]] && 1>&2 echo '${wrapper_prefix} not defined for __fzf_obc_update_complete' && return 1
  [[ -z "${trap_prefix}" ]] && 1>&2 echo '${trap_prefix} not defined for __fzf_obc_update_complete' && return 1
  # Get complete function not already wrapped
  local complete_loaded_functions_arr=($(complete | grep -o -- '-F.*' | cut -d ' ' -f 2 | sort -u | grep -v "^${wrapper_prefix}"))
  # Loop over loaded function to create a wrapper to it
  local f
  for f in "${complete_loaded_functions_arr[@]}";do
    wrapper_name="${wrapper_prefix}${f}"
    wrapper_function='__fzf_obc_read_compreply'
    # Create the wrapper if not exist
    if ! type -t "${wrapper_name}" 2>&1 > /dev/null; then
      eval "
        ${wrapper_name}() {
          shopt -u globstar
          local cur prev words cword split cpl_status;
          _init_completion -s || return;
          ${f} \$@ || cpl_status=\$?
          if type -t __fzf_obc_post_${f} 2>&1 > /dev/null;then
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
    local new_complete=($(complete | grep -E -- "-F ${f}( |$)" | sed -r "s/-F ${f}( |$)/-F ${wrapper_name}\1/;s/ $//"))
    local w
    for w in "${new_complete[@]}";do
      if [[ "${w}" != "complete -F ${wrapper_name}" ]];then
        eval "${w}"
      fi
    done
  done
  # Loop over existing trap and add them
  local loaded_traps_arr=($(declare -F | grep -E -o -- "-f ${trap_prefix}.*" | awk '{print $2}' | sort -u))
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
  __fzf_obc_cleanup
  __fzf_obc_init_vars
  __fzf_obc_load
  __fzf_obc_update_complete
}

_fzf_obc
