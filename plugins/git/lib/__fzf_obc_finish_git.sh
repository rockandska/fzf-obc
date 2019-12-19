#!/usr/bin/env bash
__fzf_obc_finish_git() {
	#############
	# DIff view #
	#############
	if  [[ "${current_plugin:-}" == "git/diff" ]];then
		__fzf_obc_plugin_git_diff_finish
	fi

	##############
	# Add viewer #
	##############
	if  [[ "${current_plugin}" == "git/add" ]];then
		__fzf_obc_plugin_git_add_finish
	fi
}
