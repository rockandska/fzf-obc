__fzf_obc_finish_git() {
	#############
	# DIff view #
	#############
	if  [[ "${current_git_cmd}" == "diff" ]];then
		if ((current_git_is_ref)) && ((current_fzf_multi));then
			if [[ "${#COMPREPLY[@]}" -eq 2 ]];then
				__fzf_compreply < <(printf '%s..%s\0' "${COMPREPLY[0]%% }" "${COMPREPLY[1]%% }")
			fi
		fi
	fi

	##############
	# Add viewer #
	##############
	if  [[ "${current_plugin}" == "git/add" ]];then
		if ((current_git_is_file));then
				if [[ "${#COMPREPLY}" -gt 0 ]];then
				__fzf_compreply < <(
					printf '%s\0' "${COMPREPLY[@]}" \
						| sed -r -z 's/^.*]\t//' \
						| sed -r -z 's/.* -> +//'
				)
			fi
		fi
	fi
}
