#!/usr/bin/env bash

# @description Looping over trigger type by length to detect it
__fzf_obc_trap__get_comp_words_by_ref() {
	# Update :
	# cur
	# words
	# Set :
	# current_cur
	# current_prev
	# current_words
	# current_cword
	__fzf_obc_detect_trigger
	if [[ -n "${current_trigger_type}" ]];then
		__fzf_obc_cfg_get current "${current_trigger_type}" "--all"	"${current_cmd_name}" "${current_plugin}"
	fi
}

__fzf_obc_add_trap() {
	local f="$1"
	shift
	local trap=__fzf_obc_trap_${f}
	# Ensure that the function exist
	type -t "${f}" > /dev/null 2>&1 || return 1
	# Get the original definition
	local origin
	origin=$(declare -f "${f}" | tail -n +3 | head -n -1)
	# Quit if already surcharged
	[[ "${origin}" =~ ${trap} ]] && return 0
	# Add trap
	local add_trap='trap '"'"''${trap}' "$?" $@; trap - RETURN'"'"' RETURN'
	origin=$(echo "${origin}" | sed -r "/${trap}/d")
	eval "
		${f}() {
			${add_trap}
			${origin}
		}
	"
}

__fzf_obc_add_all_traps() {
	# Loop over existing trap and add them
	local f
	local loaded_trap
	while IFS= read -r loaded_trap;do
		f="${loaded_trap/__fzf_obc_trap_}"
		__fzf_obc_add_trap "$f"
	done < <(declare -F | grep -E -o -- "-f __fzf_obc_trap_.*" | awk '{print $2}')
}
