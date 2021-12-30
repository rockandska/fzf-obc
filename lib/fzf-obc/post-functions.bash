#!/usr/bin/env bash

__fzf_obc_post__completion_loader() {
	__fzf_obc_add_all_traps
}

__fzf_obc_run_post_cmd() {
	if ((${current_enable:-})) && [[ -n "${current_cmd_name:-}" ]];then
		if type -t "__fzf_obc_post_${current_cmd_name:-}" > /dev/null 2>&1;then
			__fzf_obc_cfg_get current_enable "${current_trigger_type}" "enable"	"${current_cmd_name}" "${current_plugin}"
			"__fzf_obc_post_${current_cmd_name}" || return $?
		fi
	fi
}
