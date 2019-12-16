#!/usr/bin/env bash
__fzf_obc_finish_kill() {
	local IFS=$'\n'
	case ${current_prev:-} in
		-s|-l)
			return 0
			;;
	esac;
	if [[ ${current_cword:-} -eq 1 && "${current_cur:-}" == -* ]]; then
		return 0
	else
		##########################
		# Processes fuzzy finder #
		##########################
		# shellcheck disable=SC2154
		if ((current_enable));then
			if [[ "${#COMPREPLY[@]}" -gt 0 ]];then
				__fzf_compreply < <(tr '\n' '\0' < <(awk '{print $2}' <(printf '%s\n'	"${COMPREPLY[@]}")))
			fi
			return 0
		fi
	fi
}
