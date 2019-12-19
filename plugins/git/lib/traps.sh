#!/usr/bin/env bash
__fzf_obc_trap___git_main() {
	# shellcheck disable=SC2034
	current_git_cmd="${command:-}"
}

__fzf_obc_trap___git_complete_refs() {
	# shellcheck disable=SC2034
	current_git_is_ref=1
}

__fzf_obc_trap___git_complete_index_file() {
	# shellcheck disable=SC2034
	current_git_is_file=1
}
