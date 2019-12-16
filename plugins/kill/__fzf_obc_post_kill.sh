#!/usr/bin/env bash
__fzf_obc_post_kill() {
	local IFS=$'\n'
	case ${current_prev:-} in
		-s|-l)
			return 0
			;;
	esac;
	if [[ ${current_cword:-} -eq 1 && "${current_cur:-}" == -* ]]; then
		return 0
	else
		###############################
		# Processes fuzzy finder #
		###############################
		__fzf_obc_load_plugin_config process
		# shellcheck disable=SC2154
		if ((current_enable));then
			__fzf_compreply < <(command ps -ef \
				| sed 1d \
				| tr '\n' '\0'
			)
		fi
	fi
}
