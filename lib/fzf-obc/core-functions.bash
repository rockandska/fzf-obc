#!/usr/bin/env bash

__fzf_obc_get_env() {
  local env
  IFS= read -r -d '' env <<'EOF'
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

    local wrapper_prefix='__fzf_obc_wrapper_'
    local post_prefix='__fzf_obc_post_'
    local trap_prefix='__fzf_obc_trap_'
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
EOF
  echo "${env}"
}

__fzf_obc_add_trap() {
  : "${wrapper_prefix:?Not defined in ${FUNCNAME[0]}}"
  : "${post_prefix:?Not defined in ${FUNCNAME[0]}}"
  : "${trap_prefix:?Not defined in ${FUNCNAME[0]}}"
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

__fzf_add2compreply() {
  # Input: string separated by $'\0'
  if ! readarray -d $'\0' -O "${#COMPREPLY[@]}" COMPREPLY 2> /dev/null;then
    while IFS=$'\0' read -r -d '' line;do COMPREPLY+=( "${line}" );done
  fi
}

__fzf_compreply() {
  # Input: string separated by $'\0'
  if ! readarray -d $'\0' COMPREPLY 2> /dev/null;then
    IFS=$'\0' read -r -d '' -a COMPREPLY
  fi
}

__fzf_obc_colorized() {
  local IFS=' '
  local ls_colors_arr
  IFS=':' read -r -a ls_colors_arr <<< "${LS_COLORS}"
  declare -A fzf_obc_colors_arr
  local arg
  local r
  for arg in "${ls_colors_arr[@]}";do
    IFS='=' read -r -a r <<< "${arg}"
    if [[ "${r[0]}" == "*"* ]];then
      fzf_obc_colors_arr[ext_${r[0]/\*\.}]="${r[1]}"
    else
      fzf_obc_colors_arr[type_${r[0]}]="${r[1]}"
    fi
  done

  while IFS=$'\0' read -r -d '' line;do
    type="${line:0:2}"
    file="${line:3}"
    if [[ "${type}" == "fi"  ]];then
      ext="${file##*.}"
      printf "%s \e[${fzf_obc_colors_arr[ext_${ext}]:-0}m%s\e[0m\0" "${type}" "$file"
    else
      printf "%s \e[${fzf_obc_colors_arr[type_${type}]:-0}m%s\e[0m\0" "${type}" "$file"
    fi
  done
}

# get find exclude pattern
__fzf_obc_globs_exclude() {
  local var=$1
  local sep str fzf_obc_globs_exclude_array
  IFS=':' read -r -a fzf_obc_globs_exclude_array <<< "${FZF_OBC_EXCLUDE_PATH}"
  if [[ ${#fzf_obc_globs_exclude_array[@]} -ne 0 ]];then
    str="\( -path '*/${fzf_obc_globs_exclude_array[0]%/}"
    for pattern in "${fzf_obc_globs_exclude_array[@]:1}";do
      __fzf_obc_expand_tilde_by_ref pattern
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


# To use custom commands instead of find, override __fzf_obc_search later
# Return: list of files/directories separated by $'\0'
__fzf_obc_search() {
  local IFS=$'\n'
  local cur type xspec
  cur="${1}"
  type="${2}"
  xspec="${3}"

  local cur_expanded
  cur_expanded=${cur:-./}

  __fzf_obc_expand_tilde_by_ref cur_expanded

  local startdir
  if [[ "${cur_expanded}" != *"/" ]];then
    startdir="${cur_expanded}*"
    mindepth="0"
    maxdepth="0"
  else
    startdir="${cur_expanded}"
    mindepth="1"
    maxdepth="1"
  fi

  if ((${fzf_obc_is_glob:-0}));then
    maxdepth="${FZF_OBC_GLOBS_MAXDEPTH}"
    local exclude_string
    __fzf_obc_globs_exclude exclude_string
  fi

  local cmd
  cmd=""
  cmd="command find ${startdir}"
  cmd+=" -mindepth ${mindepth} -maxdepth ${maxdepth}"
  cmd+=" ${exclude_string}"
  if [[ "${type}" == "paths" ]] || [[ "${type}" == "dirs" ]];then
    cmd+=" -type d \( -perm -o=+t -a -perm -o=+w \) -printf 'tw %p/\0'"
    cmd+=" -or"
    cmd+=" -type d \( -perm -o=+w \) -printf 'ow %p/\0'"
    cmd+=" -or"
    cmd+=" -type d \( -perm -o=+t -a -perm -o=-w \) -printf 'st %p/\0'"
    cmd+=" -or"
    cmd+=" \( -type l -a -xtype d -printf 'ln %p/\0' \)"
    cmd+=" -or"
    cmd+=" -type d -printf 'di %p/\0'"
  fi
  if [[ "${type}" == "paths" ]];then
    cmd+=" -or"
  fi
  if [[ "${type}" == "paths" ]] || [[ "${type}" == "files" ]];then
    cmd+=" -type b -printf 'bd %p\0'"
    cmd+=" -or"
    cmd+=" -type c -printf 'cd %p\0'"
    cmd+=" -or"
    cmd+=" -type p -printf 'pi %p\0'"
    cmd+=" -or"
    cmd+=" \( -type l -a -xtype l -printf 'or %p\0' \)"
    cmd+=" -or"
    cmd+=" -type s -printf 'so %p\0'"
    cmd+=" -or"
    cmd+=" -type f \( -perm -u=x -o -perm -g=x -o -perm -o=x \) -printf 'ex %p\0'"
    cmd+=" -or"
    cmd+=" \( -type l -a -xtype f -printf 'ln %p\0' \)"
    cmd+=" -or"
    cmd+=" -type f -printf 'fi %p\0'"
  fi

  cmd+=" 2> /dev/null"

  if [[ "${cur_expanded}" != "${cur}" ]];then
    cmd=" sed -z s'#${cur_expanded//\//\\/}#${cur//\//\\/}#' < <(${cmd})"
  fi

  if [[ -n "${xspec}" ]];then
    cmd=" __fzf_obc_search_filter_bash '${xspec}' < <(${cmd})"
  fi

  if ((${fzf_obc_is_glob:-0}));then
    if [[ "${FZF_OBC_GLOBS_COLORS}" == "1" ]] && [[ "${#LS_COLORS}" -gt 0 ]];then
      cmd="__fzf_obc_colorized < <(${cmd})"
    fi
  else
    if [[ "${FZF_OBC_COLORS}" == "1" ]] && [[ "${#LS_COLORS}" -gt 0 ]];then
      cmd="__fzf_obc_colorized < <(${cmd})"
    fi
  fi

  cmd="cut -z -d ' ' -f2- < <(${cmd})"

  eval "${cmd}"
  return 0
}

__fzf_obc_search_filter_bash() (
  # Input: a list of strings separated by $'\0'
  # Params:
  #   $1: an optional glob patern for filtering
  # Return: a list of strings filtered and separate by $'\0'
  shopt -s extglob
  local xspec line type file filename
  xspec="$1"
  [[ -z "${xspec}" ]] && cat
  while IFS= read -t 0.1 -d $'\0' -r line;do
    type="${line:0:2}"
    file="${line:3}"
    filename="${file##*/}"
    if [[ "${type}" =~ ^(st|ow|tw|di)$ ]];then
      printf "%s\0" "${line}"
    else
      # shellcheck disable=SC2053
      [[ "${filename}" == ${xspec} ]] && printf "%s\0" "${line}"
    fi
  done
)

__fzf_obc_expand_tilde_by_ref ()
{
  local expand
  # Copy from original bash complete
  if [[ ${!1} == \~* ]]; then
    read -r -d '' expand < <(printf ~%q "${!1#\~}")
    eval "$1"="${expand}";
  fi
}

__fzf_obc_tilde ()
{
  # Copy from original bash complete
  local result=0;
  if [[ $1 == \~* && $1 != */* ]]; then
      mapfile -t COMPREPLY < <( compgen -P '~' -u -- "${1#\~}" )
      result=${#COMPREPLY[@]};
      [[ $result -gt 0 ]] && compopt -o filenames 2> /dev/null;
  fi;
  return "${result}"
}

__fzf_obc_cmd() {
    fzf --read0 --print0 --ansi
}

__fzf_obc_check_empty_compreply() {
  if [[ "${fzf_obc_is_glob:-0}" -ne 0 ]];then
    compopt +o filenames
    if [[ "${#COMPREPLY[@]}" -eq 0 ]];then
      compopt -o nospace
      COMP_WORDS[${COMP_CWORD}]="${COMP_WORDS[${COMP_CWORD}]%\*\*}"
      __fzf_add2compreply < <(printf '%s\0' "${COMP_WORDS[${COMP_CWORD}]}" )
      [[ -z "${COMPREPLY[*]}" ]] && COMPREPLY=(' ')
    fi
  fi
}

__fzf_obc_read_compreply() {
  : "${_fzf_obc_complete_func_name:?Missing complete function name in ${FUNCNAME[0]}}"
  : "${_fzf_obc_complete_cmd_name:?Missing complete command name in ${FUNCNAME[0]}}"
  local fzf_obc_is_glob="${fzf_obc_is_glob:?}"
  local IFS=$'\n'
  local cmd
  if [[ "${#COMPREPLY[@]}" -ne 0 ]];then
    if ((fzf_obc_is_glob));then
      cmd="printf '%s\0' \"\${COMPREPLY[@]}\""
      cmd="__fzf_obc_sort < <($cmd)"
      cmd=$'FZF_DEFAULT_OPTS="--reverse --height ${FZF_OBC_HEIGHT} ${FZF_OBC_GLOBS_OPTS} ${FZF_OBC_GLOBS_BINDINGS}" __fzf_obc_cmd'" < <($cmd)"
      cmd="local item;while IFS= read -d $'\0' -r item;do sed 's/^\\\~/~/g' < <(printf '%q ' \"\${item}\");done < <($cmd)"
      cmd="sed 's/ $//' < <($cmd)"
      cmd="__fzf_compreply < <($cmd)"
      eval "$cmd"
    else
      cmd="printf '%s\0' \"\${COMPREPLY[@]}\""
      cmd="__fzf_obc_sort < <($cmd)"
      cmd=$'FZF_DEFAULT_OPTS="--reverse --height ${FZF_OBC_HEIGHT} ${FZF_OBC_OPTS} ${FZF_OBC_BINDINGS}" __fzf_obc_cmd'" < <($cmd)"
      cmd="sed 's#/\x0#\x0#' < <($cmd)"
      cmd="__fzf_compreply < <($cmd)"
      eval "$cmd"
    fi
    printf '\e[5n'
  fi
  __fzf_obc_check_empty_compreply
}

__fzf_obc_load_user_functions() {
  local fzf_obc_path_array path file
  IFS=':' read -r -a fzf_obc_path_array <<< "${FZF_OBC_PATH:-}"
  for path in "${fzf_obc_path_array[@]}";do
    for file in "${path}"/*.{sh,bash} ; do
      [[ -e "${file}" && ! -d "${file}" ]] || continue
      # shellcheck disable=SC1090
      source "${file}"
    done
  done
}

__fzf_obc_update_complete() {
  eval "$(__fzf_obc_get_env)"
  : "${wrapper_prefix:?Not defined in ${FUNCNAME[0]}}"
  : "${post_prefix:?Not defined in ${FUNCNAME[0]}}"
  : "${trap_prefix:?Not defined in ${FUNCNAME[0]}}"
  # Get complete function not already wrapped
  local wrapper_name
  local func_name
  local complete_def
  local complete_def_arr
  while IFS= read -r complete_def;do
    IFS=' ' read -r -a complete_def_arr <<< "${complete_def}"
    func_name="${complete_def_arr[${#complete_def_arr[@]}-2]}"
    wrapper_name="${wrapper_prefix}${func_name}"
    if ! type -t "${wrapper_name}" > /dev/null 2>&1 ; then
      local cmd
      read -r -d '' cmd <<-EOF
        ${wrapper_name}() {
          trap 'eval "\$previous_globstar_setting"' RETURN
          local previous_globstar_setting=\$(shopt -p globstar);
          shopt -u globstar
          local _fzf_obc_complete_func_name="${func_name}"
          local _fzf_obc_complete_cmd_name="\${1}"
          local fzf_obc_is_glob=0
          local complete_status=0
          ${func_name} \$@ || complete_status=\$?
          __fzf_obc_run_post_cmd
          __fzf_obc_read_compreply
          # always check complete wrapper
          # example: tar complete function is update on 1st exec
          __fzf_obc_update_complete
          return \$complete_status
        }
			EOF
			eval "$cmd"
    fi
    complete_def_arr[${#complete_def_arr[@]}-2]="${wrapper_name}"
    eval "${complete_def_arr[@]}"
  done < <(complete | grep -E -- '-F ([^ ]+)( |$)' | grep -v " -F ${wrapper_prefix}" | sed -r "s/(-F [^ ]+) ?$/\1 ''/")
}

__fzf_obc_add_all_traps() {
  eval "$(__fzf_obc_get_env)"
  # Loop over existing trap and add them
  local f
  local loaded_trap
  while IFS= read -r loaded_trap;do
    f="${loaded_trap/${trap_prefix}}"
    __fzf_obc_add_trap "$f"
  done < <(declare -F | grep -E -o -- "-f ${trap_prefix}.*" | awk '{print $2}')
}
