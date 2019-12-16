#!/usr/bin/env bash

__fzf_obc_git_addfiles2compreply() {
	local args="${1:-}"
	# Fill COMPREPLY with files if -- is present and COMPREPLY is empty
	# shellcheck disable=SC2154
	[[ "${#COMPREPLY}" -eq 0 ]] \
		&& __fzf_obc_check_string_in_array "--" "${current_words[@]}" \
		&& cur="${current_cur}" __git_complete_index_file "${args}"
}

__fzf_obc_git_add_files_status() {
	local files
	files=$(printf '%q ' "${COMPREPLY[@]}")
	# shellcheck disable=SC1090
	__fzf_compreply < <(source <(
		cat <<-EOF
		# bug with git status and -z so using newline as separator.
		__git -c color.status=always -c status.relativePaths=true status --short $files 2> /dev/null \
		| sed 's/^\(..[^[:space:]]* *\) "\(.*\)$/\1 \2/;s/ -> "/ -> /;s/^\(..[^[:space:]]* *\) \(.*\)$/[\1]\t\2/;s/"$//' \
		| tr '\n' '\0'
		EOF
	))
}

__fzf_obc_git_rm_files_status() {
	if [[ "${#COMPREPLY}" -gt 0 ]];then
		# remove file status
		__fzf_compreply < <(
			printf '%s\0' "${COMPREPLY[@]}" \
				| sed -r -z 's/^.*]\t//' \
				| sed -r -z 's/.* -> +//'
		)
	fi
}
