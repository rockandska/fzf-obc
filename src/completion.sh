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
	local sort_cmd=(sort)
	local current_sort_opts
	__fzf_obc::config::get current "${current_trigger:-}" "sort_opts"	"${current_cmd:-}"
	if ((${#current_sort_opts[@]}));then
		sort_cmd=("${sort_cmd[@]}" "${current_sort_opts[@]:-}")
	fi
	__fzf_obc::log::debug "sort command arguments :" "${sort_cmd[@]}"
	__fzf_obc::log::debug "COMPREPLY before sort :" "${COMPREPLY[@]}"
	IFS=$'\n' read -r -d '' -a COMPREPLY < <( printf "%s\n" "${COMPREPLY[@]}" |	LC_ALL=C "${sort_cmd[@]}" | uniq ; printf '\0' )
	__fzf_obc::log::debug "COMPREPLY after sort :" "${COMPREPLY[@]}"
}

__fzf_obc::completion::fzf() {
	local IFS=$'\n'
	local fzf_cmd=('fzf' '--select-1' '--exit-0' '--height=40%' '--reverse'	'--bind' 'tab:accept')
	__fzf_obc::log::debug "Displaying results with fzf"
	__fzf_obc::log::debug "fzf command arguments :" "${fzf_cmd[@]}"
	local ROW_BEFORE COL_BEFORE ROW_AFTER COL_AFTER
	IFS=';' read -sdR -p $'\E[6n' ROW_BEFORE COL_BEFORE
	tput cud 1
	IFS=$'\n' read -r -d '' -a COMPREPLY < <( printf "%s\n" "${COMPREPLY[@]}" | "${fzf_cmd[@]}" ; printf '\0' )
	IFS=';' read -sdR -p $'\E[6n' ROW_AFTER COL_AFTER
	ROW=$(("${ROW_AFTER#*[}" - "${ROW_BEFORE#*[}" + "${ROW_BEFORE#*[}"))
	tput cup $(($ROW - 2)) $(($COL_BEFORE - 1))
	# redraw line
	#printf '\e[5n'
}
