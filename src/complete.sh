#!/usr/bin/env bash
__fzf_obc::complete::wrapper::FUNC_NAME() {
	__fzf_obc::log::debug::var COMP_TYPE

	# Backup old globstar setting
	trap 'eval "$previous_globstar_setting"' RETURN
	local previous_globstar_setting
	previous_globstar_setting="$(shopt -p globstar 2> /dev/null)"
	shopt -u globstar 2> /dev/null

	# shellcheck disable=SC2034
	{
	local current_cmd="${1}"
	local current_func_name="FUNC_NAME"
	local current_trigger # set by __fzf_obc::trigger::detect
	local current_cword_trigger_start_pos # set by __fzf_obc::trigger::clean
	local current_func_args=("$@")
	}

	local complete_status=0

	if [[ "${FZF_OBC_DISABLED:-0}" -eq 0 ]];then
		__fzf_obc::log::debug <<-DEBUG
			fzf-obc is enabled
			check if a trigger is found
		DEBUG

		if [[ "$COMP_CWORD" -gt "0" ]];then
			__fzf_obc::trigger::detect
		fi

		# Backup COMP_CWORD, COMP_LINE, COMP_POINT, COMP_WORDS
		COMP_CWORD_BACKUP="$COMP_CWORD"
		COMP_LINE_BACKUP="$COMP_LINE"
		COMP_POINT_BACKUP="$COMP_POINT"
		COMP_WORDS_BACKUP=("${COMP_WORDS[@]}")
		# Call original complete function
		"${current_func_name}" "${current_func_args[@]}" || complete_status="$?"
		# Restore (sudo update the variables for exemple)
		COMP_CWORD="$COMP_CWORD_BACKUP"
		COMP_LINE="$COMP_LINE_BACKUP"
		COMP_POINT="$COMP_POINT_BACKUP"
		COMP_WORDS=("${COMP_WORDS_BACKUP[@]}")

		__fzf_obc::log::debug "${current_func_name} returned status : $complete_status"

		if [[ -n "${current_trigger:-}" ]];then
			# completion is done, displaying it with fzf
			__fzf_obc::completion::show
			# Some completion function update the complete definition on first load
			# So, check if complete definition is up to date
			__fzf_obc::complete::update
		fi
	else
		__fzf_obc::log::debug "fzf-obc is disabled"
		"${current_func_name}" "$@" || complete_status="$?"
		__fzf_obc::log::debug "${current_func_name} returned status : $complete_status"
	fi

	return ${complete_status:-0}
}

__fzf_obc::complete::update() {
	local IFS=$'\n'
	local complete_function
	local wrapper_prefix="__fzf_obc::complete::wrapper::"
	local tmp
	__fzf_obc::log::debug "Looping over complete functions not tweak yet"
	while IFS= read -r complete_function;do
		__fzf_obc::log::debug "Create ${wrapper_prefix}${complete_function} from ${complete_function}"
		tmp=$(declare -f "${wrapper_prefix}FUNC_NAME" | sed "s#FUNC_NAME#${complete_function}#g")
		# shellcheck disable=SC1091
		source /dev/stdin <<-WRAPPER_DEF
		$tmp
		WRAPPER_DEF
		__fzf_obc::log::debug "Update complete definitions who use ${complete_function}"
		tmp=$(complete | grep -E -- "-F ${complete_function}( |$)" | sed -r "s/-F ([^ ]+) /-F ${wrapper_prefix}\1 /;s/ $/ ''/")
		# shellcheck disable=SC1091
		source /dev/stdin <<-COMPLETE_DEF
		$tmp
		COMPLETE_DEF
	done < <(complete | grep -Eo -- '-F ([^ ]+)( |$)' | grep -v -- "-F ${wrapper_prefix}" | sed -r -- 's/(-F | $)//g' | sort -u || true)
}

__fzf_obc::complete::script() {
	local _cmd="${1:-}"
	local _tmp
	local _wrapper_prefix="__fzf_obc::complete::wrapper::"
	_tmp="$(complete -p "${_cmd}" | sed -r "s/.*-F //;s/${_wrapper_prefix}//;s/ .*//")"
	if [ -n "${_output_var:-}" ];then
		printf -v "${_output_var}" '%s' "${_tmp}"
	else
		echo "${_tmp}"
	fi
	return 0
}
