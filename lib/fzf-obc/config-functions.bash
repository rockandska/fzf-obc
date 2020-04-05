#!/usr/bin/env bash

__fzf_obc_load_user_functions() {
	local fzf_obc_path_array path file
	IFS=':' read -r -a fzf_obc_path_array <<< "${FZF_OBC_PATH:-}"
	for path in "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc" "${fzf_obc_path_array[@]}";do
		while IFS= read -r -d '' file;do
			[[ -e "${file}" && ! -d "${file}" ]] || continue
			# shellcheck disable=SC1090
			source "${file}"
		done < <(find "${path}" -type f \( -name '*.sh' -o -name '*.bash' \) -print0 2>/dev/null)
	done
}

__fzf_obc_load_plugin_config() {
	: "${current_cmd_name:?Missing complete command name in ${FUNCNAME[0]}}"
	: "${fzf_obc_path:?Missing fzf_obc_path in ${FUNCNAME[0]}}"

	local plugin="${1:-}"
	if [[ -z "${plugin}" ]];then
		plugin="default"
	else
		plugin="${current_cmd_name}/${plugin}"
	fi

	# shellcheck disable=SC1090
	source <(
		for path in "${fzf_obc_path}" "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc";do
			if [[ -r "${path}/plugins/${plugin}.cfg" ]];then
				# shellcheck disable=SC1090
				source "${path}/plugins/${plugin}.cfg"
			fi
		done

		__fzf_obc_set_enable_opts

		if((${current_enable:-}));then
			# shellcheck disable=SC2034
			current_plugin="${plugin}"
			# shellcheck disable=SC2154
			declare -p "${fzf_obc_options_arr[@]}" "current_enable" "current_plugin" 2> /dev/null \
				| sed -r 's/^declare -[a-zA-Z-]+ ([^=]+)=(.*)/\1=\2;/'
		else
			# Keep only [trigger]_enable/current_enable vars if disable
			# shellcheck disable=SC2154
			declare -p "current_enable" 2>	/dev/null \
				| sed -r 's/^declare -[a-zA-Z-]+ ([^=]+)=(.*)/\1=\2;/'
		fi
	)
}

__fzf_obc_load_config() {
	local option_type="fzf_trigger"
	local trigger_size=-1
	local trigger_type
	local option
	local option_value

	local config="${1:-default}"
	# shellcheck disable=SC1090
	source <(
		if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/${config}.cfg" ]];then
			# shellcheck disable=SC1090
			source "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/${config}.cfg"
		fi

		__fzf_obc_set_trigger_opts

		# shellcheck disable=SC2154
		for trigger_type in "${trigger_type_arr[@]}";do
			option="${trigger_type}_${option_type}"
			if [[ -n "${!option}" ]];then
				printf -v option_value '^(.*)%q$' "${!option}"
			else
				option_value="^(.*)$"
			fi
			if [[ "${cur}" =~ ${option_value} ]];then
				if [[ "${#option_value}" -gt "${trigger_size}" ]];then
					trigger_size="${#option_value}"
					# shellcheck disable=SC2034
					current_cur="${BASH_REMATCH[1]}"
					# shellcheck disable=SC2034
					current_trigger_type="${trigger_type}"
				fi
			fi
		done

		__fzf_obc_set_enable_opts

		if((${current_enable:-}));then
			# shellcheck disable=SC2154
			declare -p "${fzf_obc_options_arr[@]}" "current_enable" "current_trigger_type"	"current_cur" 2> /dev/null \
				| sed -r 's/^declare -[a-zA-Z-]+ ([^=]+)=(.*)/\1=\2;/'
		else
			# Keep only current_enable vars if disable
			declare -p "current_enable" 2> /dev/null \
				| sed -r 's/^declare -[a-zA-Z-]+ ([^=]+)=(.*)/\1=\2;/'
		fi
	)
}
