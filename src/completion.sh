#!/usr/bin/env bash
__fzf_obc::completion::show() {
	if [ "${#COMPREPLY[@]}" -gt 0 ];then
		__fzf_obc::log::debug 'COMPREPLY is not empty'
		__fzf_obc::completion::sort
		__fzf_obc::completion::fzf
	else
		__fzf_obc::log::debug 'COMPREPLY is empty'
	fi
}

__fzf_obc::completion::sort() {
	local IFS=$'\n'
	local sort_cmd=(sort -u)
	__fzf_obc::log::debug "sort command arguments :" "${sort_cmd[@]}"
	__fzf_obc::log::debug "COMPREPLY before sort :" "${COMPREPLY[@]}"
	IFS=$'\n' read -r -d '' -a COMPREPLY < <( printf "%s\n" "${COMPREPLY[@]}" | LC_ALL=C "${sort_cmd[@]}" ; printf '\0' )
	__fzf_obc::log::debug "COMPREPLY after sort :" "${COMPREPLY[@]}"
}

__fzf_obc::completion::fzf() {
	local IFS=$'\n'
	local fzf_cmd=('fzf' '--select-1' '--exit-0' '--height=40%' '--reverse'	'--bind' 'tab:accept')
	__fzf_obc::log::debug "Displaying results with fzf"
	__fzf_obc::log::debug "fzf command arguments :" "${fzf_cmd[@]}"
	IFS=$'\n' read -r -d '' -a COMPREPLY < <( printf "%s\n" "${COMPREPLY[@]}" | "${fzf_cmd[@]}" ; printf '\0' )
	# redraw line
	printf '\e[5n'
}
