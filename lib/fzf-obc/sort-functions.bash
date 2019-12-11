#!/usr/bin/env bash

__fzf_obc_sort() {
	: "${current_func_name:?Missing complete function name in ${FUNCNAME[0]}}"
	: "${current_cmd_name:?Missing complete command name in ${FUNCNAME[0]}}"
	# try sort function for the completed cmd first
	if type "__fzf_obc_sort_${current_cmd_name}" &> /dev/null;then
		"__fzf_obc_sort_${current_cmd_name}"
	# then, try sort function for the complete function
	elif type "__fzf_obc_sort_${current_func_name}" &> /dev/null;then
		"__fzf_obc_sort_${current_func_name}"
	# or default
	else
		__fzf_obc_default_sort ""
	fi
}

__fzf_obc_default_sort() {
	(set -euo pipefail; eval "LC_ALL=C sort -z -u ${current_sort_opts:-} -S 50% --parallel=\"$(awk	'/^processor/{print $3}' /proc/cpuinfo 2> /dev/null | wc -l)\" 2> /dev/null" || eval "LC_ALL=C sort -z -u ${current_sort_opts:-}")
}
