#!/usr/bin/env bash

#####
# This files is a template sourced by __fzf_obc_update_complete
# It creates __fzf_obc_wrapper_::FUNC_NAME:: function
#####

__fzf_obc_wrapper_::FUNC_NAME::() {
	# Backup old globstar setting
	trap 'eval "$previous_globstar_setting"' RETURN
	local previous_globstar_setting
	previous_globstar_setting=$(shopt -p globstar);
	shopt -u globstar

	# Internal vars
	# shellcheck disable=SC2034
	local fzf_obc_path="::FZF_OBC_PATH::" \
				current_func_name="::FUNC_NAME::" \
				current_filedir_depth \
				current_trigger_type \
				current_cur \
				current_prev \
				current_words \
				current_cword \
				current_plugin \
				fzf_default_opts \
				current_cmd_name="${1}" \
				complete_status=0 \
				fzf_obc_options_arr=()

	# Declare local variables by trigger type
	# Standard, Multi selection, Recursive
	local trigger_type_arr=(
			"std"
			"mlt"
			"rec"
		)

	# Declare all options type
	local options_type_arr=(
			"fzf_trigger"
			"fzf_multi"
			"fzf_opts"
			"fzf_binds"
			"fzf_size"
			"fzf_position"
			"fzf_tmux"
			"fzf_colors"
			"sort_opts"
			"filedir_short"
			"filedir_colors"
			"filedir_hidden_first"
			"filedir_maxdepth"
			"filedir_exclude_path"
		)

	# loop to declare all variables as local
	# local [trigger_type]_[options_type]
	# local current_[options_type]
	local current_enable
	local x y
	for x in "${trigger_type_arr[@]}";do
		for y in "${options_type_arr[@]}";do
			eval "local ${x}_${y}"
			eval "local current_${y}"
			fzf_obc_options_arr+=("current_${y}" "${x}_${y}")
		done
		eval "local ${x}_enable"
	done

	${current_func_name} "$@" || complete_status=$?

	if ((${current_enable:-}));then
		__fzf_obc_load_plugin_config
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
