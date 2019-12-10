#!/usr/bin/env bash

# @description Looping over trigger type by length to detect it
__fzf_obc_trap__get_comp_words_by_ref() {
	local trigger_type
	local option_type="fzf_trigger"
	local trigger_size=-1
	local option
	local option_value
	local new_cur="$cur"
	: "${trigger_type_arr:=trigger_type_arr not init in ${FUNCNAME[@]}}"
	for trigger_type in "${trigger_type_arr[@]}";do
		option="${trigger_type}_${option_type}"
		option_value="${!option}"
		if [[ ${cur} =~ (.*)"${option_value}" ]];then
			if [[ "${#option_value}" -gt "${trigger_size}" ]];then
				trigger_size="${#option_value}"
				# shellcheck disable=SC2034
				current_trigger="${trigger_type}"
				new_cur="${BASH_REMATCH[1]}"
			fi
		fi
	done
	cur="${new_cur}"
	# shellcheck disable=SC2034
	current_cur="${cur:-}"
	# shellcheck disable=SC2034
	current_prev="${prev:-}"
	# shellcheck disable=SC2034
	current_words="${words:-}"
	# shellcheck disable=SC2034
	current_cword="${cword:-}"
}
