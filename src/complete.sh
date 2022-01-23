#!/usr/bin/env bash
__fzf_obc::complete::wrapper::FUNC_NAME() {
	__fzf_obc::log::debug "COMP_TYPE :" "${COMP_TYPE}"
	# shellcheck disable=SC2034
	{
	local current_cmd_name="${1}"
	local current_func_name="FUNC_NAME"
	}

	local complete_status=0

	"${current_func_name}" "$@" || complete_status="$?"
	__fzf_obc::log::debug "${current_func_name} returned status :" "$complete_status"

	if [[ "${FZF_OBC_DISABLED:-0}" -eq 0 ]];then
		__fzf_obc::log::debug "fzf-obc is enabled"
		# completion is done, displaying it with fzf
		__fzf_obc::completion::show
		# Some completion function update the complete definition on first load
		# So, check if complete definition is up to date
		__fzf_obc::complete::update
	else
		__fzf_obc::log::debug "fzf-obc is disabled"
	fi

	return $complete_status
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

