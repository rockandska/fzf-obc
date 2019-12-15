#!/usr/bin/env bash
__fzf_obc_post_git() {
	
	# Fill COMPREPLY with files if -- is present and COMPREPLY is empty
	[[ "${#COMPREPLY}" -eq 0 ]] \
		&& __fzf_obc_check_string_in_array "--" "${current_words[@]}" \
		&& cur="${current_cur}" __git_complete_index_file "--cached --others --directory"

	###############
	# Diff viewer #
	###############
	if  [[ "${current_git_cmd}" == "diff" ]];then
		if ((current_git_is_ref)) || ((current_git_is_file));then
			__fzf_obc_load_plugin_config diff
		fi
	fi

	##############
	# Add viewer #
	##############
	if  [[ "${current_git_cmd}" == "add" ]];then
		if ((current_git_is_file));then
			__fzf_obc_load_plugin_config add
			local files
			files=$(printf '%q ' "${COMPREPLY[@]}")
			__fzf_compreply < <(source <(
				cat <<-EOF
				# bug with git status and -z so using newline as separator.
				__git -c color.status=always -c status.relativePaths=true status --short $files 2> /dev/null \
				| sed 's/^\(..[^[:space:]]*\) "\(.*\)$/\1 \2/;s/ -> "/ -> /;s/^\(..[^[:space:]]*\) \(.*\)$/[\1]\t\2/;s/"$//' \
				| tr '\n' '\0'
				EOF
			))
		fi
	fi

}
