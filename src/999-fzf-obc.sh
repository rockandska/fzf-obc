#!/usr/bin/env bash
fzf-obc() {
	# To redraw line after fzf closes (printf '\e[5n')
	bind '"\e[0n": redraw-current-line' &> /dev/null || true
	__fzf_obc::log::debug "Start fzf-obc"
	__fzf_obc::complete::update
	__fzf_obc::trap::add::all
}

if [[ "${BASH_SOURCE[0]}" != "${0}" ]];then
	if [[ "${FZF_OBC_DISABLED:-0}" -eq 0 ]];then
		fzf-obc
	fi
else
	__fzf_obc::log::error "fzf-obc should be sourced not executed" "Exit"
fi
