#!/usr/bin/env bash
__fzf_obc::completion::show() {
	__fzf_obc::log::debug::var \
		COMPREPLY \
		COMP_CWORD \
		COMP_LINE \
		COMP_POINT \
		COMP_WORDS
	if [ "${#COMPREPLY[@]}" -eq 0 ];then
		__fzf_obc::log::debug 'COMPREPLY is empty'
	elif [ "$(__fzf_obc::completion::sort <(printf -- '%s\n' "${COMPREPLY[@]}") | wc -l)" -eq 1 ];then
		__fzf_obc::log::debug 'COMPREPLY is not empty and uniq'
	else
		__fzf_obc::log::debug 'COMPREPLY is not empty'
		if __fzf_obc::completion::longestprefix;then
			bind '"\e[0n": abort'
			printf '\e[5n'
		else
			local curpos
			__fzf_obc::tools::get_cursor_pos curpos
			tput cud1
			local USER_CHOICE
			IFS=$'\n' read -r -d '' -a USER_CHOICE < <(__fzf_obc::completion::fzf; printf '\0')
			tput cuu1
			if [[ "${#USER_CHOICE[@]}" -ge 1 ]];then
				__fzf_obc::log::debug 'User choice'
				__fzf_obc::log::debug::var "COMPREPLY"
				local BACKUP_COMPREPLY=("${USER_CHOICE[@]}")
				local shortest
				if __fzf_obc::completion::findshortest "${USER_CHOICE[0]}" "COMPREPLY" shortest;then
					COMPREPLY=("${shortest}")
				fi
				# Update COMPREPLY COMP_CWORD COMP_LINE COMP_POINT COMP_WORDS with
				# actual choice to call the completion a 2nd time
				__fzf_obc::readline::update
				# Get actual completion script
				_output_var="current_func_name" __fzf_obc::complete::script "${current_cmd}"
				# 2nd call to completion script
				__fzf_obc::log::debug 'Second call to completion function'
				"${current_func_name}" "${current_func_args[@]}" || complete_status="$?"
				__fzf_obc::log::debug::var "COMPREPLY"
				IFS=$'\n' read -r -d '' -a COMPREPLY < <(__fzf_obc::completion::sort <(printf -- '%s\n' "${COMPREPLY[@]}"))
				if [[ "${#COMPREPLY[@]}" -gt 1 ]];then
					__fzf_obc::log::debug "New COMPREPLY > 1, restore previous COMPREPLY"
					# revert to the 1st choice
					COMPREPLY=("${BACKUP_COMPREPLY[@]}")
					#__fzf_obc::completion::show
				elif [[ "${BACKUP_COMPREPLY[0]}" =~ ([$COMP_WORDBREAKS]) ]] && [[ "${BACKUP_COMPREPLY[0]}" != "${COMPREPLY[0]}"* ]];then
					__fzf_obc::log::debug::var COMPREPLY BACKUP_COMPREPLY
					__fzf_obc::log::debug <<-DEBUG
						A COMP_WORDBREAKS was in the previous COMPREPLY
						but the new COMPREPLY doesn't include the previous one.
						Readd the part before COMP_WORDBREAKS in the new COMPREPLY.
					DEBUG
					# bash:3.2.5 -> 3.2.57 (docker run bash:3.2.5<TAB>)
					# Readd the part before the COMP_WORDBREAK found
					#COMPREPLY=("${BACKUP_COMPREPLY[0]%${BACKUP_COMPREPLY[0]##*${BASH_REMATCH[1]}}}${COMPREPLY[0]}")
					COMPREPLY=("${BACKUP_COMPREPLY[@]}")
				fi
			fi
			tput cuf "${curpos[1]}"
		fi
		if [[ "${#COMPREPLY[@]}" -eq 0 ]];then
			__fzf_obc::log::debug 'COMPREPLY is empty'
			compopt -o nospace +o filenames 2> /dev/null || true
		fi
	fi
}

# shellcheck disable=SC2120
__fzf_obc::completion::sort() {
	local IFS=$'\n'
	LC_ALL=C command uniq < <(LC_ALL=C command sort < "${1:-/dev/stdin}")
}

__fzf_obc::completion::fzf() {
	local IFS=$'\n'
	local fzf_cmd=('fzf' '--select-1' '--exit-0' '--height=40%' '--reverse'	'--bind' 'tab:accept')
	__fzf_obc::log::debug \
		"Displaying results with fzf" \
		"fzf command arguments :" "${fzf_cmd[@]}"
	# Display results with fzf
	"${fzf_cmd[@]}"	< <(__fzf_obc::completion::sort	< <(printf -- "%s\n" "${COMPREPLY[@]}"))
}

# shellcheck disable=SC2120
__fzf_obc::completion::longestprefix() {
	local IFS=$'\n'
	local _prefix
	local _var="${1-}"
	local _insensitive=0
	if __fzf_obc::readline::completion_ignore_case;then
		_insensitive=1
	else
		_insensitive=0
	fi
	local _awk_script
	read -r -d '' _awk_script <<-'EOF' || true
		# Original from https://rosettacode.org/wiki/Longest_common_prefix#AWK
		# Updated to do the job based on stdin
		BEGIN {
			i=0
		}
		{
			line[++i] = $0
		}
		END {
			printf(lcp(line,i,insensitive))
		}
		function lcp(arr,n,insensitive,  hits,i,j,lcp_leng,sw_leng,sw,s1,s2) {
			if (n == 0) { # null string
				return("")
			}
			if (n == 1) { # only 1 word, then it's the longest
				return(arr[1])
			}
			sw_leng = length(arr[1])
			sw = arr[1]
			for (i=2; i<=n; i++) { # find shortest word length
				if (length(arr[i]) < sw_leng) {
					sw_leng = length(arr[i])
					sw = arr[i]
				}
			}
			for (i=1; i<=sw_leng; i++) { # find longest common prefix
				hits = 0
				for (j=1; j<n; j++) {
					if (insensitive == "1") {
						s1 = tolower(substr(arr[j],1,i))
						s2 = tolower(substr(arr[j+1],1,i))
					} else {
						s1 = substr(arr[j],1,i)
						s2 = substr(arr[j+1],1,i)
					}
					if ( s1 == s2 ) {
						hits++
					}
					else {
						break
					}
				}
				if (hits == 0) {
					break
				}
				if (hits + 1 == n) {
					lcp_leng++
				}
			}
			return(substr(sw,1,lcp_leng))
		}
	EOF
	_prefix=$(command awk -v insensitive="$_insensitive" -f <(echo "$_awk_script") <(__fzf_obc::completion::sort <(printf -- '%s\n' "${COMPREPLY[@]}")))

	if [[ "${_prefix:${current_cword_trigger_start_pos}}" != "" ]];then
		__fzf_obc::log::debug "Found prefix '${_prefix}'"
		__fzf_obc::log::debug::var _prefix
		if [[ -n "${_var}" ]];then
			printf -v "${_var}" -- '%s' "${_prefix}"
		fi
		return 0
	fi
	return 1
}

# shellcheck disable=SC2120
__fzf_obc::completion::findshortest() {
	# Find common prefix in COMPREPLY
	# based on the user choice
	local IFS=$'\n'
	local _prefix
	local _choice="${1-}"
	local _input="${2:-}"
	local _output_var="${3-}"
	local _insensitive=0
	local _tmp="${_input}[@]"
	if __fzf_obc::readline::completion_ignore_case;then
		_insensitive=1
	else
		_insensitive=0
	fi
	local _awk_script
	read -r -d '' _awk_script <<-'EOF' || true
		BEGIN {
			i=0
		}
		{
			line[++i] = $0
		}
		END {
			printf(lcp(line,i,choice,insensitive))
		}
		function lcp(arr,n,choice,insensitive,hits,i,j,lcp_leng,sw_leng,sw,s1,s2) {
			if (n == 0) { # null string
				return("")
			}
			if (n == 1 && arr[1] == choice) { # only 1 word and same as choice
				return(arr[1])
			}
			sw_leng = length(choice)
			sw = choice
			for (i=1; i<=sw_leng; i++) { # find longest common prefix
				hits = 0
				for (j=1; j<=n; j++) {
					if (arr[j] == choice) {
						continue
					}
					if (insensitive == "1") {
						s1 = tolower(substr(arr[j],0,i))
						s2 = tolower(substr(choice,0,i))
					} else {
						s1 = substr(arr[j],0,i)
						s2 = substr(choice,0,i)
					}
					if ( s1 == s2 ) {
						hits++
					}
					else {
						continue
					}
				}
				if (hits == 0) {
					break
				}
				else {
					lcp_leng++
				}
			}
			return(substr(sw,1,lcp_leng+1))
		}
	EOF
	_prefix=$(
		command awk \
			-v choice="${_choice}" \
			-v insensitive="$_insensitive" \
			-f <(echo "$_awk_script") \
			<(__fzf_obc::completion::sort <(printf -- '%s\n' "${!_tmp}"))
	)

	if [[ "${_prefix:-}" != "" ]];then
		__fzf_obc::log::debug "Found short prefix '${_prefix}' based on '${_choice}'"
		__fzf_obc::log::debug::var _prefix
		if [[ -n "${_output_var}" ]];then
			printf -v "${_output_var}" -- '%s' "${_prefix}"
		fi
		return 0
	fi
	return 1
}

