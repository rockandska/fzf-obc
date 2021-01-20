#!/usr/bin/env bash

__fzf_obc::readline::completion_ignore_case() {
	local status
	IFS=" " read -r -d $'\n' _ _ status < <(bind -v 2> /dev/null | grep completion-ignore-case)
	if [[ "${status:-}" == "on" ]];then
		return 0
	else
		return 1
	fi
}

__fzf_obc::readline::update() {
	# Update COMP_CWORD / COMP_LINE / COMP_POINT / COMP_WORDS
	# based on what was choosed in COMPREPLY
	# COMPREPLY=('abc', 'abcd', 'abcde')
	if [[ "${#COMPREPLY[@]}" -gt 1 ]];then
		__fzf_obc::log::error "COMPREPLY > 1"
	fi
	local compreply="${COMPREPLY[0]}"
	__fzf_obc::log::debug::var compreply

	############
	# Cleaning #
	############

	# remove trailing space
	# example: git add space to COMPREPLY
	compreply="${compreply%"${compreply##*[![:space:]]}"}"
	# remove trailing /
	# example! make add / for targets in COMPREPLY
	compreply="${compreply%/}"

	local tmp_comp_line="${COMP_LINE}"
	local trigger_start_pos=${COMP_POINT}
	local comp_line_size="${#COMP_LINE}"
	local cword="${COMP_WORDS[$COMP_CWORD]}"
	local cword_size="${#cword}"
	if  [[ "$cword_size" -eq 1 ]] && [[ "${COMP_WORDBREAKS}" == *"$cword"* ]];then
		((COMP_CWORD++))
	fi

	local i
	for ((i=0; i<COMP_CWORD; i++))
	do
		tmp_comp_line="${tmp_comp_line/${COMP_WORDS[$i]}}"
		# remove leading space
		tmp_comp_line="${tmp_comp_line#"${tmp_comp_line%%[![:space:]]*}"}"
	done

	local tmp_comp_line_size="${#tmp_comp_line}"

	# an index relative to COMP_LINE
	local cword_start_pos="$((comp_line_size-tmp_comp_line_size))"
	#local cword_end_pos="$((comp_line_size-tmp_comp_line_size+cword_size))"

	local new_cword="${compreply}${cword:$((COMP_POINT - cword_start_pos))}"
	local new_cword_size="${#new_cword}"

	__fzf_obc::log::debug::var \
		COMPREPLY \
		COMP_CWORD \
		COMP_LINE \
		COMP_POINT \
		COMP_WORDS \
		trigger_start_pos \
		cword \
		cword_size \
		cword_start_pos \
		cword_end_pos \
		comp_line_size \
		new_cword \
		new_cword_size \
		current_cword_trigger_start_pos

	COMP_POINT="$((COMP_POINT + (new_cword_size - cword_size)))"
	COMP_WORDS[$COMP_CWORD]="${new_cword}"
	COMP_LINE="${COMP_LINE:0:${cword_start_pos}}${compreply}${COMP_LINE:$trigger_start_pos}"
	# Si COMP_WORDS[$COMP_CWORD] contient ${COMP_WORDBREAKS}
#	COMP_POINT=17
#	COMP_CWORD=4
#	COMP_WORDS[4]="${new_cword}"
#	COMP_LINE="docker run bash:${new_cword}"

	__fzf_obc::log::debug::var \
		COMP_CWORD \
		COMP_LINE \
		COMP_POINT \
		COMP_WORDS \
		COMPREPLY

}
