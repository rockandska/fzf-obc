#!/usr/bin/env bash

__fzf_obc_run_finish_cmd() {
	: "${current_func_name:?Missing complete function name in ${FUNCNAME[0]}}"
	: "${current_cmd_name:?Missing complete command name in ${FUNCNAME[0]}}"

	if type -t "__fzf_obc_finish_${current_func_name}" > /dev/null 2>&1;then
		"__fzf_obc_finish_${current_func_name}" || return $?
	fi
	if [[ "${current_func_namename}" != "_completion_loader" ]];then
		if type -t "__fzf_obc_finish_${current_cmd_name}" > /dev/null 2>&1;then
			"__fzf_obc_finish_${current_cmd_name}" || return $?
		fi
	fi
}
