#!/usr/bin/env bash
__fzf_obc::log() {
	local IFS=$' \n'
	local level="$1" && shift
	local funcname=("${FUNCNAME[@]:2}")
	local funcname_len=$((${#funcname[@]} - 2))
	local origin="${funcname[0]:-main}"
	local date
	date=$(date +'%Y-%m-%d %H:%M:%S')
	local func_depth_str
	printf -v func_depth_str "%0.s    |" $(seq 0 ${funcname_len})
	local l
	for l in "$@";do
		1>&2 printf '%s - %s - %s %s - %s\n' "${date:-}" "${level:-}" "${func_depth_str}" "${origin:-}" "${l:-}"
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
		__fzf_obc::log DEBUG "$@"
	fi
}
