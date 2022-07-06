#!/usr/bin/env bash
__fzf_obc::trigger::detect() {
	# called by __fzf_obc::trap::function::_get_comp_words_by_ref
	# set current_trigger (declared in wrapper function)
	local triggers_arr
	__fzf_obc::config::get::triggers triggers_arr
	local trigger
	local trigger_regex
	local trigger_size=-1
	local trigger_value
	local tmp_fzf_trigger
	local tmp_fzf_trigger_size
	for trigger in "${triggers_arr[@]}";do
		__fzf_obc::config::get tmp "${trigger}" "fzf_trigger"
		if [[ -n "${tmp_fzf_trigger:-}" ]];then
			__fzf_obc::log::debug "Trigger '${trigger}' value is '${tmp_fzf_trigger:-}'"
			printf -v trigger_regex '^(.*)%q$' "${tmp_fzf_trigger:-}"
			tmp_fzf_trigger_size="${#tmp_fzf_trigger}"
		else
			__fzf_obc::log::debug "Trigger '${trigger}' value is ''"
			trigger_regex="^(.*)$"
			tmp_fzf_trigger_size="0"
		fi
		if [[ "${cur}" =~ ${trigger_regex} ]];then
			__fzf_obc::log::debug "Found trigger '${trigger}'"
			if [[ "${tmp_fzf_trigger_size}" -gt "${trigger_size}" ]];then
				__fzf_obc::log::debug "Trigger length is longer than the previous one. Set current_trigger to '${trigger}'"
				trigger_size="${tmp_fzf_trigger_size:-}"
				trigger_value="${tmp_fzf_trigger:-}"
				# shellcheck disable=SC2034
				current_trigger="${trigger}"
			else
				__fzf_obc::log::debug "Trigger length is shorter than the previous one"
			fi
		else
			__fzf_obc::log::debug "Trigger '${trigger}' not found"
		fi
	done
	# shellcheck disable=SC2154
	__fzf_obc::log::debug "Original values :" "cur :" "${cur}" "prev :" "${prev}" "words :" "${words[@]}" "cword :" "${cword}"
	# Escape trigger value
	printf -v trigger_value '%q' "${trigger_value:-}"
	# shellcheck disable=SC2034
	cur="${cur%${trigger_value}}"
	if [[ "${cword}" -ge 0 ]];then
		# Remove trigger value from the current word in words
		# shellcheck disable=SC2034
		words[${cword}]=${words[${cword}]%${trigger_value}}
	fi
	__fzf_obc::log::debug "Updated values :" "cur :" "${cur}" "prev :" "${prev}" "words :" "${words[@]}" "cword :" "${cword}"
}
