#!/usr/bin/env bash
__fzf_obc_post_gradle() {
	case "${current_prev:-}" in
		-b|--build-file|-c|--settings-file|-I|--init-script|-g|--gradle-user-home|--include-build|--project-cache-dir|--project-dir)
			type compopt &>/dev/null && compopt -o filenames
			return 0
			;;
		*)
			#################################################
			# Remove help comments from the display results #
			#################################################
			current_plugin=remove_comments
			__fzf_obc_cfg_get current "${current_trigger_type}" "--all"	"${current_cmd_name}" "${current_plugin}"
			return 0
	esac
}
