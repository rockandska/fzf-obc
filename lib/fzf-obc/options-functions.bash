#!/usr/bin/env bash

__fzf_obc_set_opt() {
	local trigger="${1}"; shift
	local opt="${1}"; shift
	local default="${1}"; shift
	local env_var
	# First try FZF_OBC[option_type] env
	env_var="FZF_OBC_${trigger^^}_${opt^^}"
	if [[ -n "${!env_var+x}" ]];then
		eval "${trigger}_${opt}=\"${!env_var}\""
	fi
	# Then, if additional env vars are here, take the last one
	for env_var in "$@";do
		if [[ -n "${!env_var+x}" ]];then
			eval "${trigger}_${opt}=\"${!env_var}\""
		fi
	done
	env_var="${trigger}_${opt}"
	if [[ -z "${!env_var+x}" ]];then
		eval "${trigger}_${opt}=\"${default}\""
	fi
}

__fzf_obc_set_current_opt() {
	if [[ -n "${1:-}" ]] && [[ -n "${current_trigger_type:-}" ]];then
		local value
		value="${current_trigger_type}_${1}"
		eval "current_${1}=\"${!value}\""
	fi
	return 0
}

__fzf_obc_set_filedir_opts() {
	###########################################
	# specific options for complete functions #
	#    who use _filedir / _filedir_xspec    #
	###########################################

	# display short files/path as the original completion or display the full path
	__fzf_obc_set_opt std filedir_short '1' 'FZF_OBC_SHORT_FILEDIR'
	__fzf_obc_set_opt mlt filedir_short "${std_filedir_short:?}" 'FZF_OBC_SHORT_FILEDIR'
	__fzf_obc_set_opt rec filedir_short "${std_filedir_short:?}" 'FZF_OBC_SHORT_FILEDIR'
	__fzf_obc_set_current_opt filedir_short
	# Colorized files/paths based on LS_COLORS if available
	__fzf_obc_set_opt std filedir_colors '1' 'FZF_OBC_COLORS'
	__fzf_obc_set_opt mlt filedir_colors "${std_filedir_colors:?}" 'FZF_OBC_COLORS'
	__fzf_obc_set_opt rec filedir_colors "${std_filedir_colors:?}" 'FZF_OBC_GLOBS_COLORS'
	__fzf_obc_set_current_opt filedir_colors
	# shellcheck disable=SC2034
	[[ -n "${LS_COLORS:-}" ]] || current_filedir_colors=0
	# Display hidden files firts or at the end
	__fzf_obc_set_opt std filedir_hidden_first '0'
	__fzf_obc_set_opt mlt filedir_hidden_first "${std_filedir_hidden_first:-}"
	__fzf_obc_set_opt rec filedir_hidden_first "${std_filedir_hidden_first:-}"
	__fzf_obc_set_current_opt filedir_hidden_first
	# Maximum depth for the files/path lookup
	__fzf_obc_set_opt std filedir_maxdepth '1'
	__fzf_obc_set_opt mlt filedir_maxdepth "${std_filedir_maxdepth:?}"
	__fzf_obc_set_opt rec filedir_maxdepth '999999' 'FZF_OBC_GLOBS_MAXDEPTH'
	__fzf_obc_set_current_opt filedir_maxdepth
	# Dont search files in those paths for lookup
	__fzf_obc_set_opt std filedir_exclude_path ''
	__fzf_obc_set_opt mlt filedir_exclude_path "${std_filedir_exclude_path:-}"
	__fzf_obc_set_opt rec filedir_exclude_path '.git:.svn' 'FZF_OBC_EXCLUDE_PATH'
	__fzf_obc_set_current_opt filedir_exclude_path
}

__fzf_obc_set_display_opts() {
	###########################################
	# Fzf display / usage options for fzf-obc #
	###########################################

	# fzf multi selection for fzf-obc
	__fzf_obc_set_opt std fzf_multi '0'
	__fzf_obc_set_opt mlt fzf_multi '1'
	__fzf_obc_set_opt rec fzf_multi '1'
	__fzf_obc_set_current_opt fzf_multi
	# fzf options for fzf-obc
	__fzf_obc_set_opt std fzf_opts '--select-1 --exit-0 --no-sort' 'FZF_OBC_OPTS'
	__fzf_obc_set_opt mlt fzf_opts "${std_fzf_opts:-}" 'FZF_OBC_OPTS'
	__fzf_obc_set_opt rec fzf_opts "${std_fzf_opts:-}" 'FZF_OBC_GLOBS_OPTS'
	__fzf_obc_set_current_opt fzf_opts
	# Bindings use for fzf-obc
	__fzf_obc_set_opt std fzf_binds '--bind tab:accept' 'FZF_OBC_BINDINGS'
	__fzf_obc_set_opt mlt fzf_binds '--bind tab:toggle+down;shift-tab:toggle+up' 'FZF_OBC_GLOBS_BINDINGS'
	if ((${rec_fzf_multi:-}));then
		__fzf_obc_set_opt rec fzf_binds "${mlt_fzf_binds:-}" 'FZF_OBC_GLOBS_BINDINGS'
	else
		__fzf_obc_set_opt rec fzf_binds "${std_fzf_binds:-}" 'FZF_OBC_BINDINGS'
	fi
	__fzf_obc_set_current_opt fzf_binds
	## Options only required when displaying results
	# Size of the fzf-obc selector
	__fzf_obc_set_opt std fzf_size '40%' 'FZF_OBC_HEIGHT'
	__fzf_obc_set_opt mlt fzf_size "${std_fzf_size:-}" 'FZF_OBC_HEIGHT'
	__fzf_obc_set_opt rec fzf_size "${std_fzf_size:-}" 'FZF_OBC_HEIGHT'
	__fzf_obc_set_current_opt fzf_size
	# Position of the fzf-obc selector (when using fzf-tmux)
	__fzf_obc_set_opt std fzf_position 'd'
	__fzf_obc_set_opt mlt fzf_position "${std_fzf_position:-}"
	__fzf_obc_set_opt rec fzf_position "${std_fzf_position:-}"
	__fzf_obc_set_current_opt fzf_position
	# Use fzf-tmux script if in tmux or not
	__fzf_obc_set_opt std fzf_tmux '1'
	__fzf_obc_set_opt mlt fzf_tmux "${std_fzf_tmux:-}"
	__fzf_obc_set_opt rec fzf_tmux "${std_fzf_tmux:-}"
	__fzf_obc_set_current_opt fzf_tmux
	# Colors scheme to use with fzf
	__fzf_obc_set_opt std fzf_colors 'border:15'
	__fzf_obc_set_opt mlt fzf_colors "${std_fzf_colors:-}"
	__fzf_obc_set_opt rec fzf_colors "${std_fzf_colors:-}"
	__fzf_obc_set_current_opt fzf_colors

	##################################
	# Sort (GNU) options for results #
	##################################

	__fzf_obc_set_opt std sort_opts '-Vdf'
	__fzf_obc_set_opt mlt sort_opts "${std_sort_opts:-}"
	__fzf_obc_set_opt rec sort_opts "${std_sort_opts:-}"
	__fzf_obc_set_current_opt sort_opts

	###################

}

__fzf_obc_set_trigger_opts() {
	__fzf_obc_set_opt std fzf_trigger ''
	__fzf_obc_set_opt mlt fzf_trigger '*'
	__fzf_obc_set_opt rec fzf_trigger '**'
}

__fzf_obc_set_enable_opts() {
	__fzf_obc_set_opt std enable "${current_enable:-1}"
	__fzf_obc_set_opt mlt enable "${std_enable:?}"
	__fzf_obc_set_opt rec enable "${std_enable:?}"
	__fzf_obc_set_current_opt enable
}
