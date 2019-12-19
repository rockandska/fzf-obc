#!/usr/bin/env bash
__fzf_obc_git_show_all_files() {
	# Fill COMPREPLY with files if -- is present and COMPREPLY is empty
	__git_has_doubledash \
		&& [[ "${#COMPREPLY[@]}" -eq 0 ]] \
		&& current_git_is_file=1 \
		&& _filedir
}

__fzf_obc_git_clean_compreply() {
	if [[ "${#COMPREPLY}" -gt 0 ]];then
		local compreply_copy=("${COMPREPLY[@]}")
		unset COMPREPLY
		local item
		while IFS= read -r -d '' item;do
			__fzf_add2compreply < <(printf '%s\0' "$item" | sed -z 's/.* -> //')
		done < <(printf '%b\0' "${compreply_copy[@]}")
	fi
}

__fzf_obc_git_add_files_status() {
	local compreply_copy=("${COMPREPLY[@]}")
	local path status
	unset COMPREPLY
	while IFS= read -r -d '' path;do
		! [[ "${path}" =~ \"*\" ]] &&  path="\"${path}\""
		while IFS= read -r -d '' status;do
			if [[ "${status:1:1}" != " " ]];then
				__fzf_add2compreply < <(
					printf '%s\0' "$status" \
						| sed -z -r 's/^(..) /\1\t/'
				)
			fi
		done < <(eval __git status --porcelain=v1 "${path}" | tr '\n'	'\0')
	done < <(printf '%b\0' "${compreply_copy[@]}")
}

__fzf_obc_git_rm_files_status() {
	if [[ "${#COMPREPLY}" -gt 0 ]];then
		# remove file status
		__fzf_compreply < <(
			printf '%s\0' "${COMPREPLY[@]}" \
				| sed -r -z 's/^...//' \
				| sed -r -z 's/^"//;s/"$//;s/\\\"/"/g'
		)
	fi
}
