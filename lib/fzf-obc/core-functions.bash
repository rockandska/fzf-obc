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
		fzf_obc_colors_arr[ext_${r[0]/\*\.}]="${r[1]}"
	else
		fzf_obc_colors_arr[type_${r[0]}]="${r[1]}"
	fi
	done

	while IFS=$'\0' read -r -d '' line;do
		type="${line:0:2}"
		file="${line:3}"
		if [[ "${type}" == "fi"  ]];then
			ext="${file##*.}"
			printf "%s \e[${fzf_obc_colors_arr[ext_${ext}]:-0}m%s\e[0m\0" "${type}" "$file"
		else
			printf "%s \e[${fzf_obc_colors_arr[type_${type}]:-0}m%s\e[0m\0" "${type}" "$file"
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
		__fzf_obc_get_opt "${current_trigger_type}" filedir_maxdepth maxdepth
	fi

	local slash
	if [[ -n "${current_trigger_type:-}" ]];then
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

	if [[ -n "${current_trigger_type:-}" ]];then
		# shellcheck disable=SC2154
		if ((current_filedir_colors)) && [[ "${#LS_COLORS}" -gt 0 ]];then
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
	# shellcheck disable=SC2154
	if ((current_filedir_short)) && ((current_filedir_depth));then
		fzf_default_opts+=" -d '/' --with-nth=$((current_filedir_depth+1)).. "
	elif ! ((current_filedir_short)) && ((current_filedir_depth));then
		fzf_default_opts+=" -d '/' --nth=$((current_filedir_depth+1)).. "
	fi
	: "${current_fzf_multi:-0}"
	if ((current_fzf_multi));then
		fzf_default_opts+=" -m "
	fi

	fzf_default_opts+=" --reverse --height ${current_fzf_height:-} ${current_fzf_opts:-} ${current_fzf_binds:-}"

	FZF_DEFAULT_OPTS="${fzf_default_opts}" fzf --read0 --print0 --ansi
}

__fzf_obc_check_empty_compreply() {
	: "${current_fzf_multi:-0}"
	if ((current_fzf_multi));then
		compopt +o filenames
		if [[ "${#COMPREPLY[@]}" -eq 0 ]];then
			compopt -o nospace
			COMP_WORDS[${COMP_CWORD}]="${current_cur:-}"
			__fzf_add2compreply < <(printf '%s\0' "${COMP_WORDS[${COMP_CWORD}]}" )
			[[ -z "${COMPREPLY[*]}" ]] && COMPREPLY=(' ')
		fi
	fi
	# Remove space if last reply is a long-option with args
	[[ "${#COMPREPLY[@]}" -ne 0 ]] && [[ "${COMPREPLY[-1]}" == --*= ]] && compopt -o nospace;
}

__fzf_obc_display_compreply() {
	local IFS=$'\n'
	local cmd
	if [[ "${#COMPREPLY[@]}" -ne 0 ]];then
		cmd="printf '%s\0' \"\${COMPREPLY[@]}\""
		cmd="__fzf_obc_sort < <($cmd)"
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
	: "${current_fzf_multi:-0}"
	if [[ "${#COMPREPLY[@]}" -ne 0 ]];then
		if ((current_fzf_multi));then
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

__fzf_obc_update_complete() {
	local fzf_obc_path
	fzf_obc_path=$( cd "$( dirname "${BASH_SOURCE[0]%%\/..*}" )" >/dev/null 2>&1 && pwd )
	# Get complete function not already wrapped
	local wrapper_name
	local func_name
	local complete_def
	local complete_def_arr
	while IFS= read -r complete_def;do
		IFS=' ' read -r -a complete_def_arr <<< "${complete_def}"
		func_name="${complete_def_arr[${#complete_def_arr[@]}-2]}"
		wrapper_name="__fzf_obc_wrapper_${func_name}"
		if ! type -t "${wrapper_name}" > /dev/null 2>&1 ; then
			local cmd
			read -r -d '' cmd <<-EOF
				${wrapper_name}() {
				trap 'eval "\$previous_globstar_setting"' RETURN
				local previous_globstar_setting=\$(shopt -p globstar);
				shopt -u globstar
				local current_func_name="${func_name}"
				local current_cmd_name="\${1}"
				source ${fzf_obc_path}/lib/fzf-obc/default.cfg.inc
				local complete_status=0
				${func_name} \$@ || complete_status=\$?
				if [[ -n "\${current_trigger_type}" ]];then
					__fzf_obc_run_post_cmd
					__fzf_obc_display_compreply
					__fzf_obc_run_finish_cmd
					__fzf_obc_set_compreply
				fi
				# always check complete wrapper
				# example: tar complete function is update on 1st exec
				__fzf_obc_update_complete
				return \$complete_status
				}
			EOF
			eval "$cmd"
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

__fzf_obc_get_opt() {
	local trigger_opt="${1}_${2}"
	local var="${3}"
	eval "${var}=\"${!trigger_opt}\""
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

__fzf_obc_set_all_current_opt() {
	if [[ -n "${1:-}" ]];then
		local value
		for opt in "${options_type_arr[@]:?}";do
			value="${1}_${opt}"
			eval "current_${opt}=\"${!value}\""
		done
		eval "current_trigger_type=\"${1}\""
	fi
	return 0
}
