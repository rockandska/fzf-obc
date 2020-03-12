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
				fzf_default_opts \
				current_cmd_name="${1}" \
				complete_status=0

	# Declare local variables by trigger type
	# Standard, Multi selection, Recursive
	local trigger_type_arr=(
			"std"
			"mlt"
			"rec"
		)

	# Declare all options type
	local options_type_arr=(
			"enable"
			"fzf_multi"
			"fzf_trigger"
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
	local x y
	for x in "${trigger_type_arr[@]}";do
		for y in "${options_type_arr[@]}";do
			eval "local ${x}_${y}"
			eval "local current_${y}"
		done
	done

	# load user/command config
	if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/default.cfg" ]];then
		# shellcheck disable=SC1090
		source "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/default.cfg"
	fi
	if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/${current_cmd_name:-}.cfg" ]];then
		# shellcheck disable=SC1090
		source "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/${current_cmd_name:-}.cfg"
	fi

	${current_func_name} "$@" || complete_status=$?

	if ((${current_enable:-}));then
		__fzf_obc_load_plugin_config
		((current_enable)) && __fzf_obc_run_post_cmd
		__fzf_obc_display_compreply
		((current_enable)) && __fzf_obc_run_finish_cmd
		__fzf_obc_set_compreply
	fi

	# always check complete wrapper
	# example: tar complete function is update on 1st exec
	__fzf_obc_update_complete

	return $complete_status
}
