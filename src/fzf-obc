#!/usr/bin/env bash
fzf-obc() {
	__fzf_obc::log::debug "Starting fzf-obc"
	__fzf_obc::complete::update
}

if [[ "${BASH_SOURCE[0]}" != "${0}" ]];then
	if [[ "${FZF_OBC_DISABLED:-0}" -eq 0 ]];then
		fzf-obc
	fi
else
	__fzf_obc::log::error "fzf-obc should be sourced not executed" "Exit"
fi
