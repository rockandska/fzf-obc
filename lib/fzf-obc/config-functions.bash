#!/usr/bin/env bash

__fzf_obc_load_user_functions() {
	local fzf_obc_path_array path file
	IFS=':' read -r -a fzf_obc_path_array <<< "${FZF_OBC_PATH:-}"
	for path in "${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc"	"${fzf_obc_path_array[@]:-}";do
		while IFS= read -r -d '' file;do
			[[ -e "${file}" && ! -d "${file}" ]] || continue
			# shellcheck disable=SC1090
			source "${file}"
		done < <(find "${path}" -type f \( -name '*.sh' -o -name '*.bash' \) -print0 2>/dev/null)
	done
}

__fzf_obc_load_plugin_config() {
	: "${fzf_obc_path:?Missing fzf_obc_path in ${FUNCNAME[0]}}"

	local plugin="${1:-}"
	if [[ -z "${plugin}" ]];then
		plugin="default"
	else
		plugin="${current_cmd_name:-}/${plugin}"
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

__fzf_obc_cfg2ini() {
	# Load old config format and convert it to ini style
	#
	# [default]
	# std_trigger=''
	#
	# [kill]
	# std_trigger='k'
	#
	# [kill:plugin:process]
	#
	# std_trigger='p'

	local start_dir
	if [ -n "${1+x}" ];then
		start_dir="${1}"
	else
		1>&2 echo "Missing 'start_dir'	parameter"
		return 1
	fi
	local store_var
	if [ -n "${2+x}" ];then
		store_var="${2}"
	else
		1>&2 echo "Missing 'store_var' parameter"
		return 1
	fi
	if ! [ -d "${start_dir}" ];then
		1>&2 echo -n "'${start_dir}' doesn't exist or is not readable"
		return 1
	fi
	local file
	local output
	for file in "${start_dir}"/*.cfg "${start_dir}"/plugins/default.cfg	"${start_dir}"/plugins/*/*.cfg;do
		if ((${FZF_OBC_DEBUG:-0}));then
			1>&2 echo "$file"
		fi
		local short_file="${file##${start_dir}/}"
		# Plugins config
		local regex
		regex="^((plugins/)([^/]+/)?)?([^/]+\.cfg)"
		if [[ ${short_file}  =~ $regex ]];then
			printf -v "output" '%s%s' "${output:+${output}$'\n'}" "[${BASH_REMATCH[2]:+${BASH_REMATCH[2]%?}:}${BASH_REMATCH[3]:+${BASH_REMATCH[3]%?}:}${BASH_REMATCH[4]%.cfg}]"
		else
			if ((${FZF_OBC_DEBUG:-0}));then
				1>&2 echo "Configuration file '$file' doesn't match the filename template. ignoring...."
			fi
		fi
		printf -v "output" '%s%s' "${output:+${output}$'\n'}"	"$(<"$file")"
	done
	printf -v "${store_var}" '%s' "${output}"
}

__fzf_obc_print_cfg_func() {
	# will print a function definition containing all configuration case
	# present in the directories defined as parameter
	if [ "${#@}" -eq 0 ];then
		1>&2 echo 'At least one directory where to search configuration is required'
		return 1
	fi
	printf '%s\n' '__fzf_obc_cfg_get() {'
	local dir
	for dir in "$@";do
		local ini_cfg
		# load ini file if exist
		if [ -f "${dir}/fzf-obc.ini" ];then
			ini_cfg=$(<"${dir}"/fzf-obc.ini)
		else
		# generate ini file from cfg files
			__fzf_obc_cfg2ini "${dir}" "ini_cfg"
		fi
	done
	cat <<- 'EOF'
		# __fzf_obc_cfg_get [trigger] [option] [cmd] [plugin]
		# __fzf_obc_cfg_get std fzf_trigger kill process
		local trigger="${1:-}"
		local option="${2:-}"
		local cmd="${3:-}"
		local plugin="${4:-}"

		if [ "${#@}" -eq 0 ];then
			1>&2 echo "__fzf_obc_cfg_get TRIGGER OPTION [cmd] [plugin]"
			return 1
		fi
		if [ -z "${trigger}" ];then
			1>&2 echo "${FUNCNAME[0]} : Missing 'trigger' parameter"
			return 1
		fi
		if [ -z "${option}" ];then
			1>&2 echo "${FUNCNAME[0]} : Missing 'option' parameter"
			return 1
		fi

		# Declare local variables by trigger type
		# Standard, Multi selection, Recursive
		local trigger_type_arr=(
			"std"
			"mlt"
			"rec"
		)

		# Declare all options type
		local options_type_arr=(
			"fzf_trigger"
			"fzf_multi"
			"fzf_opts"
			"fzf_binds"
			"fzf_size"
			"fzf_position"
			"fzf_tmux"
			"fzf_colors"
			"sort_opts"
			"filedir_short"
			"filedir_colors"
			"filedir_hidden_first"
			"filedir_maxdepth"
			"filedir_exclude_path"
		)

		# loop to declare all variables as local
		# local [trigger_type]_[options_type]
		local x y
		for x in "${trigger_type_arr[@]}";do
			for y in "${options_type_arr[@]}";do
				eval "local ${x}_${y}"
				eval "local current_${y}"
			done
			eval "local ${x}_enable"
		done

		# Define loading order (lower first)
		local cfg2test
		cfg2test=("default")
		if [ -n "${cmd:-}" ];then
			cfg2test+=("${cmd:-}")
		fi
		if [ -n "${cmd:-}" ] && [ -n "${plugin:-}" ];then
			cfg2test+=("plugins:default" "plugins:${cmd:-}:default" "plugins:${cmd:-}:${plugin:-}")
		fi
		local cfg_level
		for cfg_level in "${cfg2test[@]}";do
			case "${cfg_level}" in
	EOF
	local regex
	regex="^\s*\[([a-zA-Z0-9_:-]+)\]\s*$"
	local ini2bash
	local line
	while IFS= read -r -d $'\n' line;do
		if [[ $line =~ $regex ]];then
			printf -v ini2bash '%s%s\t%s\n'  "${ini2bash:-}"	"${ini2bash:+$'\n\t;;\n'}" "\"${BASH_REMATCH[1]}\")"
		else
			printf -v ini2bash '%s\t\t%s\n'	"${ini2bash:-}" "${line}"
		fi
	done <<< "${ini_cfg}"
	ini2bash="${ini2bash:+${ini2bash}$'\n'$'\t';;}"
	printf '%b\n' "${ini2bash}"
	cat <<- 'EOF'
			esac
		done

		local option2display="${trigger}_${option}"

		# Try FZF_OBC[trigger_option] env
		local env_var
		env_var="$( echo "FZF_OBC_${option2display}" | tr a-z A-Z)"
		if [[ -n "${!env_var+x}" ]];then
			eval "${option2display}=\"${!env_var}\""
		fi

		# specific case
		case "${option2display:-}" in
			${trigger}_filedir_colors)
				[[ -n "${LS_COLORS:-}" ]] || printf '%s\n' 0
				;;
		esac

		if [ -n "${!option2display:+x}" ];then
			printf '%s\n' "${!option2display:-}"
		else
			1>&2 echo "${FUNCNAME[0]} : Unknown option : '${option2display}'"
			return 1
		fi
	}
	EOF
}
