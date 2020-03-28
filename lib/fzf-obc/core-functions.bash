#!/usr/bin/env bash

__fzf_obc_add_trap() {
	local f="$1"
	shift
	local trap=__fzf_obc_trap_${f}
	# Ensure that the function exist
	type -t "${f}" > /dev/null 2>&1 || return 1
	# Get the original definition
	local origin
	origin=$(declare -f "${f}" | tail -n +3 | head -n -1)
	# Quit if already surcharged
	[[ "${origin}" =~ ${trap} ]] && return 0
	# Add trap
	local add_trap='trap '"'"''${trap}' "$?" $@; trap - RETURN'"'"' RETURN'
	origin=$(echo "${origin}" | sed -r "/${trap}/d")
	eval "
		${f}() {
			${add_trap}
			${origin}
		}
	"
}

__fzf_add2compreply() {
	# Input: string separated by $'\0'
	if ! readarray -d $'\0' -O "${#COMPREPLY[@]}" COMPREPLY 2> /dev/null;then
		while IFS=$'\0' read -r -d '' line;do COMPREPLY+=( "${line}" );done
	fi
}

__fzf_compreply() {
	# Input: string separated by $'\0'
	if ! readarray -d $'\0' COMPREPLY 2> /dev/null;then
		COMPREPLY=()
		while IFS= read -r -d $'\0' line;do COMPREPLY+=("${line}");done
	fi
}

__fzf_obc_colorized() {
	local IFS=' '
	local ls_colors_arr
	IFS=':' read -r -a ls_colors_arr <<< "${LS_COLORS}"
	declare -A fzf_obc_colors_arr
	local arg
	local r
	for arg in "${ls_colors_arr[@]}";do
	IFS='=' read -r -a r <<< "${arg}"
	if [[ "${r[0]}" == "*"* ]];then
		printf -v fzf_obc_colors_arr["ext_${r[0]/\*\.}"] "%0$((12-${#r[1]}))d%s" 0 "${r[1]}"
	else
		printf -v fzf_obc_colors_arr["type_${r[0]/\*\.}"] "%0$((12-${#r[1]}))d%s" 0 "${r[1]}"
	fi
	done

	while IFS=$'\0' read -r -d '' line;do
		type="${line:0:2}"
		file="${line:3}"
		if [[ "${type}" == "fi"  ]];then
			ext="${file##*.}"
			printf "%s \e[${fzf_obc_colors_arr[ext_${ext}]:-000000000000}m%s\0" "${type}" "$file"
		else
			printf "%s \e[${fzf_obc_colors_arr[type_${type}]:-000000000000}m%s\0" "${type}" "$file"
		fi
	done
}

# get find exclude pattern
__fzf_obc_globs_exclude() {
	local var=$1
	local sep str fzf_obc_globs_exclude_array
	IFS=':' read -r -a fzf_obc_globs_exclude_array <<< "${current_filedir_exclude_path:-}"
	if [[ ${#fzf_obc_globs_exclude_array[@]} -ne 0 ]];then
		str="\( -path '*/${fzf_obc_globs_exclude_array[0]%/}"
		for pattern in "${fzf_obc_globs_exclude_array[@]:1}";do
			__fzf_obc_expand_tilde_by_ref pattern
			if [[ "${pattern}" =~ ^/ ]];then
				sep="' -o -path '"
			else
				sep="' -o -path '*/"
			fi
			pattern=${pattern%\/}
			str+=$(printf "%s" "${pattern/#/$sep}")
		done
		str+="' \) -prune -o"
	fi
	eval "${var}=\"${str}\""
}


# To use custom commands instead of find, override __fzf_obc_search later
# Return: list of files/directories separated by $'\0'
__fzf_obc_search() {
	local IFS=$'\n'
	local cur type xspec
	cur="${1}"
	type="${2}"
	xspec="${3}"

	local cur_expanded
	cur_expanded=${cur:-./}

	__fzf_obc_expand_tilde_by_ref cur_expanded

	local startdir
	if [[ "${cur_expanded}" != *"/" ]];then
		startdir="${cur_expanded}*"
		mindepth="0"
		maxdepth="0"
	else
		startdir="${cur_expanded}"
		mindepth="1"
		maxdepth="1"
	fi

	if [[ "${current_trigger_type:-}" == "rec" ]];then
		maxdepth="${current_filedir_maxdepth:?}"
	fi

	local slash
	if ((${current_enable:-}));then
		slash="/"
	fi

	local exclude_string
	__fzf_obc_globs_exclude exclude_string

	local cmd
	cmd=""
	cmd="command find ${startdir}"
	cmd+=" -mindepth ${mindepth} -maxdepth ${maxdepth}"
	cmd+=" ${exclude_string}"
	if [[ "${type}" == "paths" ]] || [[ "${type}" == "dirs" ]];then
		cmd+=" -type d \( -perm -o=+t -a -perm -o=+w \) -printf 'tw %p${slash}\0'"
		cmd+=" -or"
		cmd+=" -type d \( -perm -o=+w \) -printf 'ow %p${slash}\0'"
		cmd+=" -or"
		cmd+=" -type d \( -perm -o=+t -a -perm -o=-w \) -printf 'st %p${slash}\0'"
		cmd+=" -or"
		cmd+=" \( -type l -a -xtype d -printf 'ln %p${slash}\0' \)"
		cmd+=" -or"
		cmd+=" -type d -printf 'di %p${slash}\0'"
	fi
	if [[ "${type}" == "paths" ]];then
		cmd+=" -or"
	fi
	if [[ "${type}" == "paths" ]] || [[ "${type}" == "files" ]];then
		cmd+=" -type b -printf 'bd %p\0'"
		cmd+=" -or"
		cmd+=" -type c -printf 'cd %p\0'"
		cmd+=" -or"
		cmd+=" -type p -printf 'pi %p\0'"
		cmd+=" -or"
		cmd+=" \( -type l -a -xtype l -printf 'or %p\0' \)"
		cmd+=" -or"
		cmd+=" -type s -printf 'so %p\0'"
		cmd+=" -or"
		cmd+=" -type f \( -perm -u=x -o -perm -g=x -o -perm -o=x \) -printf 'ex %p\0'"
		cmd+=" -or"
		cmd+=" \( -type l -a -xtype f -printf 'ln %p\0' \)"
		cmd+=" -or"
		cmd+=" -type f -printf 'fi %p\0'"
	fi

	cmd+=" 2> /dev/null"

	if [[ "${cur_expanded}" != "${cur}" ]];then
		cmd=" sed -z s'#${cur_expanded//\//\\/}#${cur//\//\\/}#' < <(${cmd})"
	fi

	if [[ -n "${xspec}" ]];then
		cmd=" __fzf_obc_search_filter_bash '${xspec}' < <(${cmd})"
	fi

	if ((${current_enable:-}));then
		if ((${current_filedir_colors:-}));then
			cmd="__fzf_obc_colorized < <(${cmd})"
		fi
	fi

	cmd="cut -z -d ' ' -f2- < <(${cmd})"

	eval "${cmd}"
	return 0
}

__fzf_obc_search_filter_bash() (
	# Input: a list of strings separated by $'\0'
	# Params:
	#   $1: an optional glob patern for filtering
	# Return: a list of strings filtered and separate by $'\0'
	shopt -s extglob
	local xspec line type file filename
	xspec="$1"
	[[ -z "${xspec}" ]] && cat
	while IFS= read -t 0.1 -d $'\0' -r line;do
		type="${line:0:2}"
		file="${line:3}"
		filename="${file##*/}"
		if [[ "${type}" =~ ^(st|ow|tw|di)$ ]];then
			printf "%s\0" "${line}"
		else
			# shellcheck disable=SC2053
			[[ "${filename}" == ${xspec} ]] && printf "%s\0" "${line}"
		fi
	done
)

__fzf_obc_expand_tilde_by_ref ()
{
	local expand
	# Copy from original bash complete
	if [[ ${!1} == \~* ]]; then
		read -r -d '' expand < <(printf ~%q "${!1#\~}")
		eval "$1"="${expand}";
	fi
}

__fzf_obc_tilde ()
{
	# Copy from original bash complete
	local result=0;
	if [[ $1 == \~* && $1 != */* ]]; then
		mapfile -t COMPREPLY < <( compgen -P '~' -u -- "${1#\~}" )
		result=${#COMPREPLY[@]};
		[[ $result -gt 0 ]] && compopt -o filenames 2> /dev/null;
	fi;
	return "${result}"
}

__fzf_obc_cmd() {
	if ((${current_filedir_short:-})) && ((${current_filedir_depth:-}));then
		fzf_default_opts+=" -d '/' --with-nth=$((current_filedir_depth+1)).. "
	elif ! ((current_filedir_short)) && ((current_filedir_depth));then
		fzf_default_opts+=" -d '/' --nth=$((current_filedir_depth+1)).. "
	fi
	if ((${current_fzf_multi:-}));then
		fzf_default_opts+=" -m "
	fi
	if [[ -n "${current_fzf_colors:-}" ]];then
		fzf_default_opts+=" --color='${current_fzf_colors}' "
	fi

	fzf_default_opts+=" --reverse --height ${current_fzf_size:-} ${current_fzf_opts:-} ${current_fzf_binds:-}"

	if((${current_fzf_tmux:-}));then
		eval "FZF_DEFAULT_OPTS=\"${fzf_default_opts}\" fzf-tmux	-${current_fzf_position:-}	${current_fzf_size:-} --  --read0 --print0 --ansi"
	else
		eval "FZF_DEFAULT_OPTS=\"${fzf_default_opts}\" fzf --read0 --print0 --ansi"
	fi
}

__fzf_obc_check_empty_compreply() {
	if ((${current_fzf_multi:-}));then
		compopt +o filenames
		if [[ "${#COMPREPLY[@]}" -eq 0 ]];then
			compopt -o nospace
			[[ -z "${COMPREPLY[*]}" ]] && COMPREPLY=(' ')
		fi
	fi
	# Remove space if last reply is a long-option with args
	[[ "${#COMPREPLY[@]}" -ne 0 ]] && [[ "${COMPREPLY[-1]}" == --*= ]] && compopt -o nospace;
}

__fzf_obc_move_hidden_files_last() {
	# shellcheck disable=SC2154
	if ((current_filedir_colors));then
		sed -z -r '/^(\x1B\[([0-9]{1,}(;[0-9]{1,})?(;[0-9]{1,})?)?[mGK])(.*\/\.|\.)/MH;//!p;$!d;x;//s/\x0//p;d'
	else
		sed -z -r '/^(.*\/\.|\.)/MH;//!p;$!d;x;//s/\x0//p;d'
	fi
}

__fzf_obc_move_hidden_files_first() {
	# shellcheck disable=SC2154
	if ((current_filedir_colors));then
		sed -z -r	'/^(\x1B\[([0-9]{1,}(;[0-9]{1,})?(;[0-9]{1,})?)?[mGK])(.*\/\.|\.)/!H;//p;$!d;g;s/\x0//p;d'
	else
		sed -z -r '/^(.*\/\.|\.)/!H;//p;$!d;g;s/\x0//p;d'
	fi
}

__fzf_obc_display_compreply() {
	local IFS=$'\n'
	local cmd

	__fzf_obc_set_display_opts

	if [[ "${#COMPREPLY[@]}" -ne 0 ]];then
		cmd="printf '%s\0' \"\${COMPREPLY[@]}\""
		if [[ -n "${current_filedir_depth:-}" ]] && ((current_filedir_colors));then
			current_sort_opts+=" -k 1.15"
		fi
		cmd="__fzf_obc_sort < <($cmd)"
		if [[ -n "${current_filedir_depth:-}" ]] &&  [[ "${current_filedir_hidden_first:-}" == 1 ]];then
			cmd="__fzf_obc_move_hidden_files_first < <($cmd)"
		elif [[ -n "${current_filedir_depth:-}" ]] && [[ "${current_filedir_hidden_first:-}" == 0 ]];then
			cmd="__fzf_obc_move_hidden_files_last < <($cmd)"
		fi
		cmd="__fzf_obc_cmd < <($cmd)"
		cmd="__fzf_compreply < <($cmd)"
		eval "$cmd"
		printf '\e[5n'
	fi
}

__fzf_obc_set_compreply() {
	local IFS=$'\n'
	local line
	local result
	if [[ "${#COMPREPLY[@]}" -ne 0 ]];then
		if ((${current_fzf_multi:-}));then
			for line in "${COMPREPLY[@]}";do
				result+=$(sed 's/^\\\~/~/g' < <(printf '%q ' "$line"))
			done
			result=${result%% }
			COMPREPLY=()
			COMPREPLY[0]="$result"
		else
			__fzf_compreply < <(printf '%s\0' "${COMPREPLY[@]}")
		fi
	fi
	__fzf_obc_check_empty_compreply
}

__fzf_obc_load_user_functions() {
	local fzf_obc_path_array path file
	IFS=':' read -r -a fzf_obc_path_array <<< "${FZF_OBC_PATH:-}"
	for path in "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc" "${fzf_obc_path_array[@]}";do
		while IFS= read -r -d '' file;do
			[[ -e "${file}" && ! -d "${file}" ]] || continue
			# shellcheck disable=SC1090
			source "${file}"
		done < <(find "${path}" -type f \( -name '*.sh' -o -name '*.bash' \) -print0 2>/dev/null)
	done
}

__fzf_obc_load_plugin_config() {
	: "${current_cmd_name:?Missing complete command name in ${FUNCNAME[0]}}"
	: "${fzf_obc_path:?Missing fzf_obc_path in ${FUNCNAME[0]}}"
	local plugin="${1:-default}"
	local trigger_regex
	printf -v trigger_regex '%s|' "${trigger_type_arr[@]:?}"
	# shellcheck disable=SC1090
	source <(
		if [[ -r "${fzf_obc_path}/plugins/${current_cmd_name}/${plugin}.cfg" ]];then
			# shellcheck disable=SC1090
			source "${fzf_obc_path}/plugins/${current_cmd_name}/${plugin}.cfg"
		fi
		if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/plugins/${current_cmd_name}/${plugin}.cfg" ]];then
			# shellcheck disable=SC1090
			source "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/plugins/${current_cmd_name}/${plugin}.cfg"
		fi
		__fzf_obc_set_current_opt enable
		if((${current_enable:-}));then
			# eval all settings if still enable
			declare -p \
				| grep -E "declare -[a-zA-Z-]+ (${trigger_regex}current)_.*=" \
				| sed -r 's/(declare -[a-zA-Z-]+ )([^=]+)(.*)/\2\3;/'
		else
			# Keep only [trigger]_enable vars if disable
			declare -p \
				| grep -E "declare -[a-zA-Z-]+ (${trigger_regex}current)_enable=" \
				| sed -r 's/(declare -[a-zA-Z-]+ )([^=]+)(.*)/\2\3;/'
		fi
	)
	if ((${current_enable:-}));then
		# shellcheck disable=SC2034
		current_plugin="${current_cmd_name:-}/${plugin}"
	fi
}

__fzf_obc_update_complete() {
	local fzf_obc_path
	fzf_obc_path=$( cd "$( dirname "${BASH_SOURCE[0]%%\/..*}" )" >/dev/null 2>&1 && pwd )
	# Get complete function not already wrapped
	local func_name
	local wrapper_name
	local complete_def
	local complete_def_arr
	while IFS= read -r complete_def;do
		IFS=' ' read -r -a complete_def_arr <<< "${complete_def}"
		func_name="${complete_def_arr[${#complete_def_arr[@]}-2]}"
		wrapper_name="__fzf_obc_wrapper_${func_name}"
		if ! type -t "${wrapper_name}" > /dev/null 2>&1 ; then
			# shellcheck disable=SC1090
			source <(
					sed "s#::FUNC_NAME::#${func_name}#g" "${fzf_obc_path}/lib/fzf-obc/wrapper.tpl.bash" \
					| sed "s#::FZF_OBC_PATH::#${fzf_obc_path}#"
			)
		fi
		complete_def_arr[${#complete_def_arr[@]}-2]="${wrapper_name}"
		eval "${complete_def_arr[@]//\\/\\\\}"
	done < <(complete | grep -E -- '-F ([^ ]+)( |$)' | grep -v " -F __fzf_obc_wrapper_" | sed -r "s/(-F [^ ]+) ?$/\1 ''/")
}

__fzf_obc_add_all_traps() {
	# Loop over existing trap and add them
	local f
	local loaded_trap
	while IFS= read -r loaded_trap;do
		f="${loaded_trap/__fzf_obc_trap_}"
		__fzf_obc_add_trap "$f"
	done < <(declare -F | grep -E -o -- "-f __fzf_obc_trap_.*" | awk '{print $2}')
}

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
