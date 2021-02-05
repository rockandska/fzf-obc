#!/sur/bin/env bash
__fzf_obc_debug() {
	if ((${FZF_OBC_DEBUG:-0}));then
		1>&2 printf 'DEBUG %s: ' "${FUNCNAME[1]:-main}"
		1>&2 printf '%s\n' "$@"
	fi
}

__fzf_obc_error() {
	1>&2 printf 'ERROR %s: ' "${FUNCNAME[1]:-main}"
	1>&2 printf '%s\n' "$@"
}
