#!/usr/bin/env bash
__fzf_obc_post_git() {
	
	###############
	# Diff viewer #
	###############
	if  [[ "${current_git_cmd}" == "diff" ]];then
		__fzf_obc_git_addfiles2compreply "--others --modified --directory --no-empty-directory"
		if ((current_git_is_ref)) || ((current_git_is_file));then
			__fzf_obc_load_plugin_config diff
			if ((current_git_is_file));then
				__fzf_obc_git_add_files_status
			fi
		fi
	fi

	##############
	# Add viewer #
	##############
	if  [[ "${current_git_cmd}" == "add" ]];then
		if ((current_git_is_file));then
			__fzf_obc_load_plugin_config add
			__fzf_obc_git_add_files_status
		fi
	fi

}
