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
