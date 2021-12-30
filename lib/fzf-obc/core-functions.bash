#!/usr/bin/env bash

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

__fzf_obc_display_compreply() {
	local IFS=$'\n'
	local cmd

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

__fzf_obc_update_complete() {
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
			source <( declare -f __fzf_obc_wrapper_::FUNC_NAME:: | sed "s#::FUNC_NAME::#${func_name}#g")
		fi
		complete_def_arr[${#complete_def_arr[@]}-2]="${wrapper_name}"
		eval "${complete_def_arr[@]//\\/\\\\}"
	done < <(complete | grep -E -- '-F ([^ ]+)( |$)' | grep -v " -F __fzf_obc_wrapper_" | sed -r "s/(-F [^ ]+) ?$/\1 ''/")
}
