__fzf_obc_git_addfiles2compreply() {
	local args="${1:-}"
	# Fill COMPREPLY with files if -- is present and COMPREPLY is empty
	[[ "${#COMPREPLY}" -eq 0 ]] \
		&& __fzf_obc_check_string_in_array "--" "${current_words[@]}" \
		&& cur="${current_cur}" __git_complete_index_file "${args}"
}
