#!/usr/bin/env bash
__fzf_obc::log() {
	local IFS=$'\n'
	local level="$1" && shift
	local funcname=("${FUNCNAME[@]:2}")
	local funcname_len=$((${#funcname[@]} - 2))
	local origin="${funcname[0]:-main}"
	local lines
	if [[ "$#" -eq 0 ]];then
		lines=("$(</dev/stdin)")
	else
		lines=("$@")
	fi
	if [[ "${FZF_OBC_LOG_PATH:-}" == "" ]];then
		local log_dir="${XDG_CACHE_HOME:-$HOME/.cache}/fzf-obc"
		local log_path="${log_dir}/fzf-obc.log"
		mkdir -p "${log_dir}"
	else
		local log_path="${FZF_OBC_LOG_PATH:-}"
	fi
	local date
	date=$(date +'%Y-%m-%d %H:%M:%S')
	local func_depth_str
	printf -v func_depth_str "%0.s    |" $(seq 0 ${funcname_len})
	local l
	for l in "${lines[@]}";do
		1>&2 printf '%s - %s - %s %s - %s\n' "${date:-}" "${level:-}" "${func_depth_str}" "${origin:-}" "${l:-}" >> "${log_path}"
	done
}

__fzf_obc::log::error() {
	local IFS=$'\n'
	__fzf_obc::log ERROR "$@"
	return 1
}

__fzf_obc::log::debug() {
	local IFS=$'\n'
	local FZF_OBC_DEBUG="${FZF_OBC_DEBUG:-0}"
	if ((FZF_OBC_DEBUG));then
		if [[ "$#" -eq 0 ]];then
			__fzf_obc::log DEBUG < /dev/stdin
		else
			__fzf_obc::log DEBUG "$@"
		fi
	fi
}

__fzf_obc::log::debug::var() {
	local IFS=$'\n'
	local FZF_OBC_DEBUG="${FZF_OBC_DEBUG:-0}"
	if ((FZF_OBC_DEBUG));then
		local vars
		IFS=$'\n' read -r -d '' -a vars < <(declare -p "$@" 2> /dev/null; printf '\0')
		if [ -n "${vars[*]}" ];then
			__fzf_obc::log DEBUG "${vars[@]}"
		fi
	fi
}
