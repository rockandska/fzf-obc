#!/usr/bin/env bash
__fzf_obc_finish_gradle() {
	case "${current_prev:-}" in
		-b|--build-file|-c|--settings-file|-I|--init-script|-g|--gradle-user-home|--include-build|--project-cache-dir|--project-dir)
		  type compopt &>/dev/null && compopt -o filenames
			return 0
			;;
		*)
			#################################################
			# Remove help comments from the display results #
			#################################################
			# shellcheck disable=SC2154
			if((current_enable));then
				local i
				for i in "${!COMPREPLY[@]}";do
					COMPREPLY[$i]="${COMPREPLY[i]%%  *}"
				done
			fi
			return 0
	esac
}
