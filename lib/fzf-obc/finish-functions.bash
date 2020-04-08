#!/usr/bin/env bash

__fzf_obc_run_finish_cmd() {
	if [[ -n "${current_plugin:-}" ]];then
		if type -t "__fzf_obc_finish_${current_cmd_name:-}" > /dev/null 2>&1;then
			"__fzf_obc_finish_${current_cmd_name}" || return $?
		fi
	fi
}
