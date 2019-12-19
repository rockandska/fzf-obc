#!/usr/bin/env bash
__fzf_obc_plugin_git_diff_finish() {
	: "${current_git_is_ref:=0}"
	: "${current_fzf_multi:=0}"
	if ((current_git_is_ref)) && ((current_fzf_multi));then
		# Merge ref if there is two ref selected
		if [[ "${#COMPREPLY[@]}" -eq 2 ]];then
			__fzf_compreply < <(printf '%s..%s\0' "${COMPREPLY[0]%% }" "${COMPREPLY[1]%% }")
		fi
	fi
}

__fzf_obc_plugin_git_add_finish() {
	: "${current_git_is_file:=0}"
	if ((current_git_is_file));then
		__fzf_obc_git_rm_files_status
		__fzf_obc_git_clean_compreply
	fi
}

