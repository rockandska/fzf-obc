#!/usr/bin/env bash

__fzf_obc_wrapper_::FUNC_NAME::() {
	# This function is a template sourced by __fzf_obc_update_complete
	# It creates __fzf_obc_wrapper_::FUNC_NAME:: function

	# Backup old globstar setting
	trap 'eval "$previous_globstar_setting"' RETURN
	local previous_globstar_setting
	previous_globstar_setting=$(shopt -p globstar);
	shopt -u globstar

	# Internal vars
	# shellcheck disable=SC2034
	{
		local current_func_name="::FUNC_NAME::"
		# Set in __fzf_obc_trap__get_comp_words_by_ref (via __fzf_obc_detect_trigger)
		local current_trigger_type
		# set in _filedir and used for shorten filepath in fzf
		local current_filedir_depth
		local current_cur
		local current_prev
		local current_words
		local current_cword
		local current_plugin
		local fzf_default_opts
		local current_cmd_name="${1}"
		local complete_status=0
		local fzf_obc_options_arr=()
	}

	# shellcheck disable=SC1090
	source <(__fzf_obc_print_options_declaration current)

	${current_func_name} "$@" || complete_status=$?

	if ((${current_enable:-}));then
		__fzf_obc_run_post_cmd
		__fzf_obc_display_compreply
		__fzf_obc_run_finish_cmd
		__fzf_obc_set_compreply
	fi

	# always check complete wrapper
	# example: tar complete function is update on 1st exec
	__fzf_obc_update_complete

	return $complete_status
}
