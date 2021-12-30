#!/usr/bin/env bash
__fzf_obc_finish_kill() {
	if [[ "${current_plugin:-}" == "process" ]];then
		##########################
		# Processes fuzzy finder #
		##########################
		if [[ "${#COMPREPLY[@]}" -gt 0 ]];then
			__fzf_compreply < <(tr '\n' '\0' < <(awk '{print $2}' <(printf '%s\n'	"${COMPREPLY[@]}")))
		fi
	fi
}
