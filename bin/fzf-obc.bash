#!/usr/bin/env bash

# To redraw line after fzf closes (printf '\e[5n')
bind '"\e[0n": redraw-current-line'

fzf-obc() {
	local fzf_obc_path
	fzf_obc_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && cd .. && pwd )

	local fzf_obc_path_array
	IFS=':' read -r -a fzf_obc_path_array <<< "${FZF_OBC_PATH:-}"
	fzf_obc_path_array=("${fzf_obc_path}/lib/fzf-obc"	"${fzf_obc_path}/plugins"	"${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc" "${fzf_obc_path_array[@]}")

	# shellcheck disable=SC1090
	source "${fzf_obc_path}/lib/fzf-obc/config-functions.bash"
	# shellcheck disable=SC1090
	source "${fzf_obc_path}/lib/fzf-obc/util-functions.bash"

	__fzf_obc_load_functions "${fzf_obc_path_array[@]}"

	# shellcheck disable=SC1090
	source <(__fzf_obc_print_cfg_func "${fzf_obc_path_array[@]}")

	complete -p fzf &> /dev/null || complete -F _longopt fzf

	__fzf_obc_update_complete
	__fzf_obc_add_all_traps

	return 0
}

fzf-obc "$@"
