#!/usr/bin/env bash

__fzf_obc_post__completion_loader() {
	__fzf_obc_add_all_traps
}

__fzf_obc_run_post_cmd() {
: "${current_cmd_name:?Missing complete command name in ${FUNCNAME[0]}}"

	if [[ -r "${fzf_obc_path}/plugins/${current_cmd_name}/default.cfg" ]];then
		source "${fzf_obc_path}/plugins/${current_cmd_name}/default.cfg"
	fi
	if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/plugins/${current_cmd_name}/default.cfg" ]];then
		source "${fzf_obc_path}/plugins/${current_cmd_name}/default.cfg"
	fi
	if ((current_enable))
		if type -t "__fzf_obc_post_${current_cmd_name}" > /dev/null 2>&1;then
			"__fzf_obc_post_${current_cmd_name}" || return $?
		fi
	fi
}
