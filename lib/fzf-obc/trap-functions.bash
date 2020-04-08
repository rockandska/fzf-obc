#!/usr/bin/env bash

# @description Looping over trigger type by length to detect it
__fzf_obc_trap__get_comp_words_by_ref() {
	__fzf_obc_load_config
	if [[ -n "${current_cmd_name:-}" ]];then
		__fzf_obc_load_config "${current_cmd_name:-}"
	fi
	if ((${current_enable:-}));then
		# shellcheck disable=SC2034
		cur="${current_cur:-}"
		# shellcheck disable=SC2034
		current_prev="${prev:-}"
		# shellcheck disable=SC2034
		current_words=("${words[@]}")
		# shellcheck disable=SC2034
		current_cword="${cword:-}"
	fi
}
