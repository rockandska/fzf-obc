#!/usr/bin/env bash

# Internal vars
local current_filedir_depth
local fzf_default_opts=""
local current_trigger_type
local current_cur
local current_prev
local current_words
local current_cword

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
		"sort_opts"
		"filedir_short"
		"filedir_colors"
		"filedir_hidden_first"
		"filedir_maxdepth"
		"filedir_exclude_path"
	)

# loop to declare all variables as local
# local [trigger_type]_[options_type]
# local [options_type]
# local current_[options_type]
local x y
for x in "${trigger_type_arr[@]}";do
	for y in "${options_type_arr[@]}";do
		eval "local ${x}_${y}"
		eval "local ${y}"
		eval "local current_${y}"
	done
done

# load user/function/command config
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/default.cfg" ]];then
	source "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/default.cfg"
fi
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/${current_func_name:-}.cfg" ]];then
	source "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/${current_func_name:-}.cfg"
fi
if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/${current_cmd_name:-}.cfg" ]];then
	source "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/${current_cmd_name}.cfg"
fi

###########################
# fzf-obc Trigger options #
###########################

# pattern who trigger fzf-obc in standard mode
__fzf_obc_set_opt std fzf_trigger ''
# pattern who trigger fzf-obc in multi selection mode
__fzf_obc_set_opt mlt fzf_trigger '*'
# pattern who trigger fzf-obc in recursive mode (for completion functions compatible)
__fzf_obc_set_opt rec fzf_trigger '**'

######################################################
# SHould we display original results or with fzf-obc #
######################################################

__fzf_obc_set_opt std enable '1'
__fzf_obc_set_opt mlt enable "${std_enable}"
__fzf_obc_set_opt rec enable "${std_enable}"

###########################################
# Fzf display / usage options for fzf-obc #
###########################################

# fzf multi selection for fzf-obc
__fzf_obc_set_opt std fzf_multi '0'
__fzf_obc_set_opt mlt fzf_multi '1'
__fzf_obc_set_opt rec fzf_multi '1'
# fzf options for fzf-obc
__fzf_obc_set_opt std fzf_opts '--select-1 --exit-0 --no-sort' 'FZF_OBC_OPTS'
__fzf_obc_set_opt mlt fzf_opts "${std_fzf_opts}" 'FZF_OBC_OPTS'
__fzf_obc_set_opt rec fzf_opts "${std_fzf_opts}" 'FZF_OBC_GLOBS_OPTS'
# Bindings use for fzf-obc
__fzf_obc_set_opt std fzf_binds '--bind tab:accept' 'FZF_OBC_BINDINGS'
__fzf_obc_set_opt mlt fzf_binds '--bind tab:toggle+down;shift-tab:toggle+up' 'FZF_OBC_GLOBS_BINDINGS'
if ((rec_fzf_multi));then
	__fzf_obc_set_opt rec fzf_binds "${mlt_fzf_binds}" 'FZF_OBC_GLOBS_BINDINGS'
else
	__fzf_obc_set_opt rec fzf_binds "${std_fzf_binds}" 'FZF_OBC_BINDINGS'
fi
# Size of the fzf-obc selector
__fzf_obc_set_opt std fzf_size '40%' 'FZF_OBC_HEIGHT'
__fzf_obc_set_opt mlt fzf_size "${std_fzf_size}" 'FZF_OBC_HEIGHT'
__fzf_obc_set_opt rec fzf_size "${std_fzf_size}" 'FZF_OBC_HEIGHT'
# Position of the fzf-obc selector (when using fzf-tmux)
__fzf_obc_set_opt std fzf_position 'r'
__fzf_obc_set_opt mlt fzf_position "${std_fzf_position}"
__fzf_obc_set_opt rec fzf_position "${std_fzf_position}"
# Use fzf-tmux script if in tmux or not
__fzf_obc_set_opt std fzf_tmux '1'
__fzf_obc_set_opt mlt fzf_tmux "${std_fzf_tmux}"
__fzf_obc_set_opt rec fzf_tmux "${std_fzf_tmux}"

##################################
# Sort (GNU) options for results #
##################################

__fzf_obc_set_opt std sort_opts '-Vdf'
__fzf_obc_set_opt mlt sort_opts "${std_sort_opts}"
__fzf_obc_set_opt rec sort_opts "${std_sort_opts}"

###########################################
# specific options for complete functions #
#    who use _filedir / _filedir_xspec    #
###########################################

# display short files/path as the original completion or display the full path
__fzf_obc_set_opt std filedir_short '1' 'FZF_OBC_SHORT_FILEDIR'
__fzf_obc_set_opt mlt filedir_short "${std_filedir_short}" 'FZF_OBC_SHORT_FILEDIR'
__fzf_obc_set_opt rec filedir_short "${std_filedir_short}" 'FZF_OBC_SHORT_FILEDIR'
# Colorized files/paths based on LS_COLORS if available
__fzf_obc_set_opt std filedir_colors '1' 'FZF_OBC_COLORS'
__fzf_obc_set_opt mlt filedir_colors "${std_filedir_colors}" 'FZF_OBC_COLORS'
__fzf_obc_set_opt rec filedir_colors "${std_filedir_colors}" 'FZF_OBC_GLOBS_COLORS'
# Display hidden files firts or at the end
__fzf_obc_set_opt std filedir_hidden_first '0'
__fzf_obc_set_opt mlt filedir_hidden_first "${std_filedir_hidden_first}"
__fzf_obc_set_opt rec filedir_hidden_first "${std_filedir_hidden_first}"
# Maximum depth for the files/path lookup
__fzf_obc_set_opt std filedir_maxdepth '1'
__fzf_obc_set_opt mlt filedir_maxdepth "${std_filedir_maxdepth}"
__fzf_obc_set_opt rec filedir_maxdepth '999999' 'FZF_OBC_GLOBS_MAXDEPTH'
# Dont search files in those paths for lookup
__fzf_obc_set_opt std filedir_exclude_path ''
__fzf_obc_set_opt mlt filedir_exclude_path "${std_filedir_exclude_path}"
__fzf_obc_set_opt rec filedir_exclude_path '.git:.svn' 'FZF_OBC_EXCLUDE_PATH'


###################

# check that all variables are set
local x y env_var
for x in "${trigger_type_arr[@]}";do
	for y in "${options_type_arr[@]}";do
		env_var="${x}_${y}"
		if [[ -z "${!env_var+x}" ]];then
			1>&2 echo "fzf-obc: '${env_var}' is not set"
		fi
	done
done
