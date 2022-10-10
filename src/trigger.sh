#!/usr/bin/env bash
__fzf_obc::trigger::clean() {
	local trigger_string="$1"
	local trigger_size="${#trigger_string}"
	local trigger_start_pos=$((COMP_POINT-trigger_size))
	local comp_line_size="${#COMP_LINE}"
	local tmp_comp_line="${COMP_LINE}"

	__fzf_obc::log::debug::var \
		COMP_CWORD \
		COMP_LINE \
		COMP_POINT \
		COMP_WORDS

	local i
	for ((i=0; i<COMP_CWORD; i++))
	do
		tmp_comp_line="${tmp_comp_line/${COMP_WORDS[$i]}}"
		# remove leading space
		tmp_comp_line="${tmp_comp_line#"${tmp_comp_line%%[![:space:]]*}"}"
	done

	local tmp_comp_line_size="${#tmp_comp_line}"
	local cword_start_pos="$((comp_line_size-tmp_comp_line_size))"
	# exposed globally for use in __fzf_obc::completion::longestprefix
	current_cword_trigger_start_pos="$((trigger_start_pos-cword_start_pos))"
	local cword="${COMP_WORDS[$COMP_CWORD]}"
	COMP_WORDS[$COMP_CWORD]="${cword:0:$((current_cword_trigger_start_pos))}${cword:$((current_cword_trigger_start_pos+trigger_size))}"
	COMP_LINE="${COMP_LINE:0:${trigger_start_pos}}${COMP_LINE:$COMP_POINT}"
	COMP_POINT="${trigger_start_pos}"

	__fzf_obc::log::debug::var \
		trigger_string \
		trigger_size \
		trigger_start_pos \
		comp_line_size \
		tmp_comp_line \
		tmp_comp_line_size \
		cword \
		cword_start_pos \
		current_cword_trigger_start_pos \
		COMP_CWORD \
		COMP_LINE \
		COMP_POINT \
		COMP_WORDS
}

__fzf_obc::trigger::get::pattern() {
	# Get the trigger pattern for $1 and return it to $2
	local ref="${1}_pattern"

	# shellcheck disable=SC2034
	local std_pattern=''

	printf -v "${2}" '%s' "${!ref:-}"
}

__fzf_obc::trigger::get() {
	# List triggers available
	local triggers=(std)
	eval "$(declare -p triggers | sed -r "s/(^[^=]*='?)/$1=/g;s/'$//")"
}

__fzf_obc::trigger::detect() {
	# called by the wrapper function before calling the original complete function
	# set current_trigger (declared in wrapper function)
	local triggers_name_arr=()
	__fzf_obc::trigger::get triggers_name_arr
	local trigger_id
	local trigger_value
	local trigger_regex
	local trigger_size=-1
	local tmp_trigger_name
	local tmp_trigger_value
	local tmp_trigger_size
	# Looking for the trigger (longest) found
	for trigger_id in "${!triggers_name_arr[@]}";do
		__fzf_obc::log::debug "Try '${triggers_name_arr[$trigger_id]}' trigger"
		tmp_trigger_name="${triggers_name_arr[$trigger_id]}"
		__fzf_obc::trigger::get::pattern "$tmp_trigger_name" tmp_trigger_value
		if [[ -n "${tmp_trigger_value:-}" ]];then
			__fzf_obc::log::debug "Trigger '${tmp_trigger_name}' value is '${tmp_trigger_value}'"
			printf -v trigger_regex '^(.*)%q$' "${tmp_trigger_value}"
			tmp_trigger_size="${#tmp_trigger_value}"
		else
			__fzf_obc::log::debug "Trigger '${tmp_trigger_name}' value is ''"
			trigger_regex="^(.*)$"
			tmp_trigger_size="0"
		fi
		if [[ "${COMP_LINE:0:$COMP_POINT}" =~ ${trigger_regex} ]];then
			__fzf_obc::log::debug "Found trigger '${tmp_trigger_name}'"
			if [[ "${tmp_trigger_size}" -gt "${trigger_size}" ]];then
				__fzf_obc::log::debug "Trigger length is longer than the previous one. Set current_trigger to '${tmp_trigger_name}'"
				trigger_size="${tmp_trigger_size:-}"
				trigger_value="${tmp_trigger_value:-}"
				# shellcheck disable=SC2034
				{
				current_trigger="${tmp_trigger_name}"
				current_trigger_size="${tmp_trigger_size}"
				}
			else
				__fzf_obc::log::debug "Trigger length is shorter than the previous one"
			fi
		else
			__fzf_obc::log::debug "Trigger '${tmp_trigger_name}' not found"
		fi
	done
	# remove trigger from completion variables
	__fzf_obc::trigger::clean "${trigger_value}"
}
