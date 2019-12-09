#!/usr/bin/env bash

__fzf_obc_post__completion_loader() {
	__fzf_obc_update_complete || return $?
}

__fzf_obc_run_post_cmd() {
: "${_fzf_obc_complete_func_name:?Missing complete function name in ${FUNCNAME[0]}}"
: "${_fzf_obc_complete_cmd_name:?Missing complete command name in ${FUNCNAME[0]}}"

	if type -t "__fzf_obc_post_${_fzf_obc_complete_func_name}" > /dev/null 2>&1;then
		"__fzf_obc_post_${_fzf_obc_complete_func_name}" || return $?
	fi
	if [[ "${_fzf_obc_complete_func_name}" != "_completion_loader" ]];then
		if type -t "__fzf_obc_post_${_fzf_obc_complete_cmd_name}" > /dev/null 2>&1;then
			"__fzf_obc_post_${_fzf_obc_complete_cmd_name}" || return $?
		fi
	fi
}

__fzf_obc_post_kill() {
	local IFS=$'\n'
	case ${actual_prev:-} in
		-s|-l)
			return 0
			;;
	esac;
	if [[ ${actual_cword:-} -eq 1 && "${actual_cur:-}" == -* ]]; then
		return 0
	else
		# Only surcharged if it is not an option
		read -r -d '' -a COMPREPLY < <(
			command ps -ef \
			| sed 1d \
			| tr '\n' '\0' \
			| FZF_DEFAULT_OPTS="--height ${FZF_OBC_HEIGHT} --min-height 15 --reverse $FZF_DEFAULT_OPTS --preview 'echo {}' --preview-window down:3:wrap $FZF_COMPLETION_OPTS -m" \
			__fzf_obc_cmd \
			| tr '\0' '\n' \
			| awk '{print $2}' \
			| tr '\n' ' ' \
			| sed 's/ $//'
		)
		printf '\e[5n'
		return 0
	fi
}
