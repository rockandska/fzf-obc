#!/usr/bin/env bash

__fzf_obc_post__completion_loader() {
	__fzf_obc_add_all_traps
}

__fzf_obc_run_post_cmd() {
	: "${current_cmd_name:?Missing complete command name in ${FUNCNAME[0]}}"
	: "${current_enable:=0}"
	if type -t "__fzf_obc_post_${current_cmd_name}" > /dev/null 2>&1;then
		"__fzf_obc_post_${current_cmd_name}" || return $?
	fi
}
