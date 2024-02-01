#!/usr/bin/env bash
__fzf_obc_finish_k() {
		#################################################
		# Remove help comments from the display results #
		#################################################
		local i
		for i in "${!COMPREPLY[@]}";do
			COMPREPLY[$i]="${COMPREPLY[i]%%  *}"
		done
		return 0
}