#!/usr/bin/env bash
__fzf_obc_post_git() {
	# shellcheck disable=SC2034
	local cur="${current_cur:-}"
	# shellcheck disable=SC2034
	local prev="${current_prev:-}"
	# shellcheck disable=SC2034
	local cword="${current_cword:-}"
	# shellcheck disable=SC2034
	local words=("${current_words[@]}")
	###############
	# Diff viewer #
	###############
	if  [[ "${current_git_cmd:-}" == "diff" ]];then
		__fzf_obc_plugin_git_diff_post
	fi

	##############
	# Add viewer #
	##############
	if  [[ "${current_git_cmd}" == "add" ]];then
		__fzf_obc_plugin_git_add_post
	fi
}
