#!/usr/bin/env bash
__fzf_obc_post_git() {
	
	###############
	# Diff viewer #
	###############
	if  [[ "${current_git_cmd:-}" == "diff" ]];then
		__fzf_obc_load_plugin_config diff
		#shellcheck disable=SC2154
		if ((current_enable));then
			__fzf_obc_git_addfiles2compreply "--others --modified --directory --no-empty-directory"
			if ((current_git_is_ref)) || ((current_git_is_file));then
				if ((current_git_is_file));then
					__fzf_obc_git_add_files_status
				fi
			fi
		fi
	fi

	##############
	# Add viewer #
	##############
	if  [[ "${current_git_cmd}" == "add" ]];then
		__fzf_obc_load_plugin_config add
		#shellcheck disable=SC2154
		if ((current_enable));then
			if ((current_git_is_file));then
				__fzf_obc_git_add_files_status
			fi
		fi
	fi

}
