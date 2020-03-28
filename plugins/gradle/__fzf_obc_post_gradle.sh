__fzf_obc_post_gradle() {
	case "$current_prev" in
		-b|--build-file|-c|--settings-file|-I|--init-script|-g|--gradle-user-home|--include-build|--project-cache-dir|--project-dir)
			type compopt &>/dev/null && compopt -o filenames
			return 0
			;;
		*)
			#################################################
			# Remove help comments from the display results #
			#################################################
			__fzf_obc_load_plugin_config remove_comments
			return 0
	esac
}
