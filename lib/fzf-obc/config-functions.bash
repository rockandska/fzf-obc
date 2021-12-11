#!/usr/bin/env bash

__fzf_obc_load_functions() {
	if [ "${#@}" -eq 0 ];then
		1>&2 echo 'At least one directory where to search functions files is required'
		return 1
	fi
	__fzf_obc_debug 'Loading functions....' 'Directories used:' "$@"
	local dir file
	for dir in "$@";do
		[[ -d "${dir}" ]] || continue
		__fzf_obc_debug "Looking in '${dir}' for .sh/.bash files..."
		while IFS= read -r -d '' file;do
			[[ -f "${file}" ]] || continue
			__fzf_obc_debug "Sourcing '${file}'..."
			# shellcheck disable=SC1090
			source "${file}"
		done < <(find "${dir}" -type f \( -name '*.sh' -o -name '*.bash' \) -print0 2>/dev/null)
	done
}

__fzf_obc_print_cfg2ini() {
	# Load old config format from 1 directory and convert it to ini style
	# $1 : directory config to print
	#
	# [DEFAULT]
	# std_trigger=''
	#
	# [kill]
	# std_trigger='k'
	#
	# [kill:plugins:process]
	#
	# std_trigger='p'

	if [ "${#@}" -eq 0 ];then
		__fzf_obc_error "One directory to convert needed"
		return 1
	elif [ "${#@}" -ne 1 ];then
		__fzf_obc_error "Only one directory to convert is allowed"
		return 1
	fi
	local start_dir
	if [ -n "${1+x}" ];then
		start_dir="${1}"
	else
		__fzf_obc_error "Missing 'start_dir' parameter"
		return 1
	fi
	if ! [ -d "${start_dir}" ];then
		__fzf_obc_error "'${start_dir}' doesn't exist or is not readable"
		return 1
	fi
	local file
	for file in "${start_dir}"/*.cfg "${start_dir}"/plugins/default.cfg	"${start_dir}"/plugins/*/*.cfg;do
		[ -f "${file}" ] || { __fzf_obc_debug "$file not found" ; continue; }
		__fzf_obc_debug "Found configuration file: $file"
		local short_file="${file##${start_dir}/}"
		# Plugins config
		local regex
		regex="^((plugins/)([^/]+/)?)?([^/]+)\.cfg$"
		if [[ ${short_file}  =~ $regex ]];then
			local plugins="${BASH_REMATCH[2]%?}"
			__fzf_obc_debug "plugins='${plugins}'"
			local cmd="${BASH_REMATCH[3]%?}"
			__fzf_obc_debug "cmd='${cmd}'"
			local plugin_name="${BASH_REMATCH[4]}"
			if [[ "${plugin_name}" == "default" ]];then
				if [[ -z "${cmd}" ]];then
					cmd="DEFAULT"
					plugins="${plugins:+plugins}"
					plugin_name=""
				else
					plugin_name=""
				fi
			fi
			__fzf_obc_debug "plugin_name='${plugin_name}'"
			local section
			section="${cmd:-}"
			section+="${plugins:+${section:+:}${plugins}}"
			section+="${plugin_name:+${section:+:}${plugin_name}}"
			__fzf_obc_debug "section='${section}'"
			printf '%s\n'	"[${section}]"
		else
			__fzf_obc_debug "Configuration file '$file' doesn't match the filename template. ignoring...."
		fi
		cat "$file"
	done
}

__fzf_obc_print_ini_config() {
	# Get fzf-obc.ini from multiples directories and print a merge of them
	# If fzf-obc.ini not present, will try to find old config files format
	# $@ : directories config to lookup
	if [ "${#@}" -lt 1 ];then
		__fzf_obc_error 'At least one argument is requiered' 'Usage :' '__fzf_obc_get_ini_config DIRECTORIES...'
		return 1
	fi
	local ini_config
	local dir
	for dir in "$@";do
		if ! [ -f "${dir}/fzf-obc.ini" ];then
			__fzf_obc_debug "'fzf-obc.ini' not found in '${dir}', try to found old config format...."
			ini_config+=$(__fzf_obc_print_cfg2ini "${dir}")
			ini_config+=$'\n'
		else
			__fzf_obc_debug "Found 'fzf-obc.ini' in '${dir}'"
			ini_config+=$(<"${dir}/fzf-obc.ini")
			ini_config+=$'\n'
		fi
	done

	# Get unique sections list
	local sections
	IFS=$'\n' read -r -d '' -a sections < <(
		# shellcheck disable=SC2016
		echo "${ini_config}" \
			| sed -r -n -e '/^\s*\[([a-zA-Z:-]+)\]\s*$/{ s/\[|\]//gp }' \
			| LC_ALL=C sort -u
		printf '\0'
	)
	local section
	for section in "${sections[@]}";do
		echo "[$section]"
		echo "${ini_config}" | sed -n -r "/^\s*\[$section\]\s*$/,/^\s*\[([a-zA-Z:-]+)\]\s*$/{ //!p }"
	done
}

__fzf_obc_print_cfg_func() {
	# will print a function definition containing all configuration case
	# present in the directories defined as parameter
	if [ "${#@}" -eq 0 ];then
		1>&2 echo 'At least one directory where to search configuration is required'
		return 1
	fi
	__fzf_obc_debug 'Generating __fzf_obc_cfg_get function....' 'Directories used:' "$@"
	printf '%s\n' '__fzf_obc_cfg_get() {'
	cat <<- 'EOF'
		# __fzf_obc_cfg_get [trigger] [option] [cmd] [plugin]
		# __fzf_obc_cfg_get std fzf_trigger kill process
		local return_var="${1:-}"
		local trigger="${2:-}"
		local option="${3:-}"
		local cmd="${4:-}"
		local plugin="${5:-}"

		if [ "${#@}" -eq 0 ];then
			__fzf_obc_error "__fzf_obc_cfg_get RETURN_VAR TRIGGER OPTION [cmd] [plugin]"
			return 1
		fi
		if [ -z "${return_var}" ];then
			__fzf_obc_error "Missing 'return_var' parameter"
			return 1
		fi
		if [ -z "${trigger}" ];then
			__fzf_obc_error "Missing 'trigger' parameter"
			return 1
		fi
		if [ -z "${option}" ];then
			__fzf_obc_error "Missing 'option' parameter"
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
			"enable"
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
				eval "local ${x}_${y}="
			done
		done

		# Define loading order (lower first)
		local cfg2test
		cfg2test=("DEFAULT")
		if [ -n "${cmd:-}" ];then
			cfg2test+=("${cmd:-}")
		fi
		if [ -n "${cmd:-}" ] && [ -n "${plugin:-}" ];then
			cfg2test+=("DEFAULT:plugins" "${cmd:-}:plugins" "${cmd:-}:plugins:${plugin:-}")
		fi
		local cfg_level
		for cfg_level in "${cfg2test[@]}";do
			case "${cfg_level}" in
	EOF
	# Transforming ini file in bash case style
	# shellcheck disable=SC2016
	sed -n -r -e '/^\s*\[.*\]\s*$/{s/\[//;s/\]/\)/;:a' -e 's/\[/;;\n/;s/\]/\)/' -e '$!N;$!ba' -e '}' -e '${s/$/\n;;/}' -e 'p' <(__fzf_obc_print_ini_config "$@")
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
				[[ -n "${LS_COLORS:-}" ]] || eval "${trigger}_filedir_colors=0"
				;;
		esac

		if [ -n "${!option2display+x}" ];then
			local is_enable="${trigger}_enable"
			local is_enable_env=$( echo "FZF_OBC_${trigger}_enable" | tr a-z A-Z)
			if ((${!is_enable_env:-${!is_enable}}));then
				printf -v "${return_var}" '%s' "${!option2display:-}"
			else
				__fzf_obc_debug "fzf-obc is disable. let the variable '${return_var}'	untouched"
			fi
		else
			__fzf_obc_error "Unknown option '${option2display}'"
			return 1
		fi
	}
	EOF
}

__fzf_obc_detect_trigger() {
	# called by __fzf_obc_trap__get_comp_words_by_ref
	local trigger_type=(std mlt rec)
	local trigger
	local trigger_value
	local trigger_regex
	local trigger_size=-1
	local current_trigger_value
	for trigger in "${trigger_type[@]}";do
		__fzf_obc_cfg_get trigger_value "${trigger}" "fzf_trigger"
		if [[ -n "${trigger_value}" ]];then
			__fzf_obc_debug "Trigger '${trigger}' value is '${trigger_value}'"
			printf -v trigger_regex '^(.*)%q$' "${trigger_value}"
		else
			__fzf_obc_debug "Trigger '${trigger}' value is ''"
			trigger_regex="^(.*)$"
		fi
		if [[ "${cur}" =~ ${trigger_regex} ]];then
			__fzf_obc_debug "Found trigger '${trigger}'"
			if [[ "${#trigger_value}" -gt "${trigger_size}" ]];then
				__fzf_obc_debug "Trigger length is longer than the previous one. Set current_trigger_type to '${trigger}'"
				trigger_size="${#trigger_value}"
				current_trigger_value="${trigger_value}"
				# shellcheck disable=SC2034
				current_cur="${BASH_REMATCH[1]}"
				# shellcheck disable=SC2034
				current_trigger_type="${trigger}"
			else
				__fzf_obc_debug "Trigger length is shorter than the previous one"
			fi
		fi
	done
	# shellcheck disable=SC2154
	__fzf_obc_debug "Original values :" "cur :" "${cur}" "prev :" "${prev}" "words :" "${words[@]}" "cword :" "${cword}"
	# shellcheck disable=SC2034
	cur="${current_cur:-${cur:-}}"
	# Escape trigger value
	printf -v current_trigger_value '%q' "${current_trigger_value:-}"
	# Remove trigger value from the current word in words
	# shellcheck disable=SC2034
	words[${cword}]=${words[${cword}]%${current_trigger_value}}
	# shellcheck disable=SC2034
	current_prev="${prev:-}"
	# shellcheck disable=SC2034
	current_words=("${words[@]}")
	# shellcheck disable=SC2034
	current_cword="${cword:-}"
	__fzf_obc_debug "Updated values :" "cur :" "${cur}" "prev :" "${prev}" "words :" "${words[@]}" "cword :" "${cword}"
}
