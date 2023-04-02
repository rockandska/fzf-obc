#!/usr/bin/env bash
__fzf_obc::tools::get_cursor_pos() {
	local _out="${1:?Missing variable argument in __fzf_obc::tools::get_cursor_pos}"
	echo -en "\E[6n"
	read -rsdR CURPOS
	IFS=";" read -ra CURPOS <<<"${CURPOS#*[}"
	CURPOS[1]=$((CURPOS[1] - 1))
	if [[ "${CURPOS[1]}" -lt 0 ]];then
		CURPOS[1]=0
	fi
	read -r -a "${_out?}" <<<"${CURPOS[@]}"
	return 0
}
