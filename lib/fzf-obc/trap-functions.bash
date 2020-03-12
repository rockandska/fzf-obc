#!/usr/bin/env bash

# @description Looping over trigger type by length to detect it
__fzf_obc_trap__get_comp_words_by_ref() {
	local option_type="fzf_trigger"
	local trigger_size=-1
	local new_cur="$cur"
	local trigger_type
	local option
	local option_value

	__fzf_obc_set_opt std fzf_trigger ''
	__fzf_obc_set_opt mlt fzf_trigger '*'
	__fzf_obc_set_opt rec fzf_trigger '**'

	__fzf_obc_set_opt std enable '1'
	__fzf_obc_set_opt mlt enable "${std_enable:?}"
	__fzf_obc_set_opt rec enable "${std_enable:?}"

	# shellcheck disable=SC2154
	for trigger_type in "${trigger_type_arr[@]}";do
		option="${trigger_type}_${option_type}"
		option_value="${!option}"
		if [[ ${cur} =~ (.*)"${option_value}" ]];then
			if [[ "${#option_value}" -gt "${trigger_size}" ]];then
				trigger_size="${#option_value}"
				new_cur="${BASH_REMATCH[1]}"
				# shellcheck disable=SC2034
				current_trigger_type="${trigger_type}"
			fi
		fi
	done

	__fzf_obc_set_current_opt enable

	if ((${current_enable:-}));then
		cur="${new_cur}"
		# shellcheck disable=SC2034
		current_cur="${cur:-}"
		# shellcheck disable=SC2034
		current_prev="${prev:-}"
		# shellcheck disable=SC2034
		current_words=("${words[@]}")
		# shellcheck disable=SC2034
		current_cword="${cword:-}"
	fi
}
