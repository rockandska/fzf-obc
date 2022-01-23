#!/usr/bin/env bash
__fzf_obc::trap::add() {
	local function="$1"
	local trap=__fzf_obc::trap::function::${function}
	# Ensure that the function exist
	if ! type -t "${function}" > /dev/null 2>&1;then
		__fzf_obc::log::debug "${function} do not exist"
		return 0
	fi
	local origin
	origin=$(declare -f "${function}")
	# Quit if already surcharged
	if [[ "${origin}" =~ ${trap} ]];then
		__fzf_obc::log::debug "Trap ${trap} already set in ${function}"
		return 0
	fi
	local tmp
	tmp=$(echo -e "${function}()\n{" ; printf $'trap \'%s "$@"; trap - RETURN\' RETURN\n' "${trap}" ; echo "$origin" | sed '1,2d;';)
	# shellcheck disable=SC1091
	source /dev/stdin <<-TRAP_DEF
	$tmp
	TRAP_DEF
	__fzf_obc::log::debug "Trap '${trap}' added to ${function}"
}

__fzf_obc::trap::add::all() {
	# Loop over existing trap and add them
	local f
	local loaded_trap
	local trap_prefix="__fzf_obc::trap::function::"
	__fzf_obc::log::debug "Search and add all trap to functions"
	while IFS= read -r loaded_trap;do
		f="${loaded_trap/${trap_prefix}}"
		__fzf_obc::log::debug "Found trap function called ${loaded_trap}" "Try to add it to ${f}"
		__fzf_obc::trap::add "$f"
	done < <(declare -F | grep -E -o -- "-f __fzf_obc::trap::function::.*" | awk '{print $2}' || true)
}

__fzf_obc::trap::function::_get_comp_words_by_ref() {
	__fzf_obc::log::debug "Set currrent_[cur,prev,words,cword]"
	# Update :
	# cur
	# words
	# Set :
	# current_cur
	# current_prev
	# current_words
	# current_cword

	# shellcheck disable=SC2034
	{
	current_cur="${cur:-}"
	current_prev="${prev:-}"
	current_words=("${words[@]:-}")
	current_cword="${cword:-}"
	}
}

