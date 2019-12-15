#!/usr/bin/env bash
__fzf_obc_trap___git_main() {
	current_git_cmd="${command:-}"
}

__fzf_obc_trap___git_complete_refs() {
	current_git_is_ref=1
}

__fzf_obc_trap___git_complete_index_file() {
	current_git_is_file=1
}
