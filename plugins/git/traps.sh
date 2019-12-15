#!/usr/bin/env bash
__fzf_obc_trap__git_diff() {
	current_git_cmd="diff"
}

__fzf_obc_trap___git_complete_refs() {
	current_git_is_ref=1
}

__fzf_obc_trap___git_complete_index_file() {
	current_git_is_file=1
}
