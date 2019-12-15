__fzf_obc_finish_git() {
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
