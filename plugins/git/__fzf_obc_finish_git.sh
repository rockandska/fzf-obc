#!/usr/bin/env bash
__fzf_obc_finish_git() {
	# shellcheck disable=SC2154
	if ((current_enable));then
		#############
		# DIff view #
		#############
		if  [[ "${current_plugin:-}" == "git/diff" ]];then
			if ((current_git_is_ref)) && ((current_fzf_multi));then
				# Merge ref if there is two ref selected
				if [[ "${#COMPREPLY[@]}" -eq 2 ]];then
					__fzf_compreply < <(printf '%s..%s\0' "${COMPREPLY[0]%% }" "${COMPREPLY[1]%% }")
				fi
			elif ((current_git_is_file));then
				__fzf_obc_git_rm_files_status
			fi
		fi

		##############
		# Add viewer #
		##############
		if  [[ "${current_plugin}" == "git/add" ]];then
			if ((current_git_is_file));then
				__fzf_obc_git_rm_files_status
			fi
		fi
	fi
}
