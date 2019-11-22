#!/usr/bin/env bash

__fzf_obc_run_finish_cmd() {
  : "${_fzf_obc_complete_func_name:?Missing complete function name in ${FUNCNAME[0]}}"
  : "${_fzf_obc_complete_cmd_name:?Missing complete command name in ${FUNCNAME[0]}}"

  if type -t "__fzf_obc_finish_${_fzf_obc_complete_func_name}" > /dev/null 2>&1;then
    "__fzf_obc_finish_${_fzf_obc_complete_func_name}" || return $?
  fi
  if [[ "${_fzf_obc_complete_func_name}" != "_completion_loader" ]];then
    if type -t "__fzf_obc_finish_${_fzf_obc_complete_cmd_name}" > /dev/null 2>&1;then
      "__fzf_obc_finish_${_fzf_obc_complete_cmd_name}" || return $?
    fi
  fi
}
