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
}
