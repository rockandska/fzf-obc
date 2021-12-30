#!/usr/bin/env bash

_filedir()
{
	local IFS=$'\n'
	local cur="${cur}"
	__fzf_obc_tilde "${cur}" || return

	# shellcheck disable=SC2001
	cur=$(echo "$cur" | sed s#//*#/#g)
	# shellcheck disable=SC2034
	current_filedir_depth="$(echo "$cur" | tr -cd '/' | wc -c )"

	if [[ "$1" != -d ]]; then
		local xspec=${1:+"*.@($1|${1^^})"};
		__fzf_add2compreply < <(__fzf_obc_search "${cur}" "paths" "${xspec}")
		[[ -n ${COMP_FILEDIR_FALLBACK:-} && -n "$1" && ${#COMPREPLY[@]} -lt 1 ]] && __fzf_add2compreply < <(__fzf_obc_search "${cur}" "paths")
	else
		__fzf_add2compreply < <(__fzf_obc_search "${cur}" "dirs")
	fi

	if [[ "${#COMPREPLY[@]}" -gt 0 ]];then
		compopt -o filenames
	fi

	return 0
}

_filedir_xspec()
{
	# shellcheck disable=SC2034
	local cur prev words cword;
	_init_completion || return;

	__fzf_obc_tilde "${cur}" || return

	# shellcheck disable=SC2001
	cur=$(echo "$cur" | sed s#//*#/#g)
	# shellcheck disable=SC2034
	current_filedir_depth="$(echo "$cur" | tr -cd '/' | wc -c )"

	local xspec
	# shellcheck disable=SC2154
	xspec="${_xspecs[${1##*/}]}"
	local matchop=!;
	if [[ $xspec == !* ]]; then
		xspec=${xspec#!};
		matchop=@;
	fi;
	xspec="$matchop($xspec|${xspec^^})";
	__fzf_add2compreply < <(__fzf_obc_search "${cur}" "paths" "${xspec}")

	if [[ "${#COMPREPLY[@]}" -gt 0 ]];then
		compopt -o filenames
	fi

	return 0
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

__fzf_obc_move_hidden_files_last() {
	# printf 'p2\x0yyy\x0.l1\x0xxx\x0.d1/' | LC_ALL=C sort -zVdf | sed -z -r -e '/^(.*\/\.|\.)/H;//!p;$!d;g;s/.//' | tr "\0" "\n'"
	# shellcheck disable=SC2154
	if ((current_filedir_colors));then
		sed -z -r '/^(\x1B\[([0-9]{1,}(;[0-9]{1,})?(;[0-9]{1,})?)?[mGK])(.*\/\.|\.)/H;//!p;$!d;g;s/.//;/^$/d;'
	else
		sed -z -r '/^(.*\/\.|\.)/H;//!p;$!d;g;s/.//;/^$/d;'
	fi
}

__fzf_obc_move_hidden_files_first() {
	#printf 'p2\x0yyy\x0.l1\x0xxx\x0.d1/' | LC_ALL=C sort -zrVdf | sed -z -r -e '/^(.*\/\.|\.)/!H;//p;$!d;g;s/.//' | tr "\0" "\n'"
	# shellcheck disable=SC2154
	if ((current_filedir_colors));then
		sed -z -r '/^(\x1B\[([0-9]{1,}(;[0-9]{1,})?(;[0-9]{1,})?)?[mGK])(.*\/\.|\.)/!H;//p;$!d;g;s/.//;/^$/d;'
	else
		sed -z -r '/^(.*\/\.|\.)/!H;//p;$!d;g;s/.//;/^$/d;'
	fi
}

