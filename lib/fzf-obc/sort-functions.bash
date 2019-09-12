#!/usr/bin/env bash

__fzf_obc_sort() {
  : "${_fzf_obc_complete_func_name:?Missing complete function name in ${FUNCNAME[0]}}"
  : "${_fzf_obc_complete_cmd_name:?Missing complete command name in ${FUNCNAME[0]}}"
  # try sort function for the completed cmd first
  if type "__fzf_obc_sort_${_fzf_obc_complete_cmd_name}" &> /dev/null;then
    "__fzf_obc_sort_${_fzf_obc_complete_cmd_name}"
  # then, try sort function for the complete function
  elif type "__fzf_obc_sort_${_fzf_obc_complete_func_name}" &> /dev/null;then
    "__fzf_obc_sort_${_fzf_obc_complete_func_name}"
  # or default
  else
    __fzf_obc_default_sort ""
  fi
}

__fzf_obc_default_sort() {
  local cmd
  # move colors to the right
  cmd="sed -z -r 's/^(\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK])(.*)/\4\1/g'"
  # sort cmd used to show results
  cmd="(eval LC_ALL=C sort -z -fru $* -S 50% --parallel=\"$( awk '/^processor/{print $3}' < /proc/cpuinfo | wc -l)\" 2> /dev/null || eval LC_ALL=C sort -z -fru $*) < <($cmd)"
  # move colors back to the left
  cmd="sed -z -r 's/(.*)(\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK])$/\2\1/g' < <($cmd)"
  eval "$cmd"
}
