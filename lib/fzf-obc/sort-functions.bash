#!/usr/bin/env bash

__fzf_obc_sort() {
	if ((${current_enable:-})) && [[ -n "${current_cmd_name:-}" ]];then
		# try sort function for the completed cmd first
		if type "__fzf_obc_sort_${current_cmd_name}" &> /dev/null;then
			"__fzf_obc_sort_${current_cmd_name}"
		else
			__fzf_obc_default_sort
		fi
	else
		__fzf_obc_default_sort
	fi
}

__fzf_obc_default_sort() {
	(set -euo pipefail; eval "LC_ALL=C sort -z -u ${current_sort_opts:-} -S 50% --parallel=\"$(awk	'/^processor/{print $3}' /proc/cpuinfo 2> /dev/null | wc -l)\" 2> /dev/null" || eval "LC_ALL=C sort -z -u ${current_sort_opts:-}")
}
