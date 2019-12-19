#!/usr/bin/env bash
__fzf_obc_plugin_git_diff_post() {
	__fzf_obc_load_plugin_config diff
	#shellcheck disable=SC2154
	if ((current_enable));then
		__fzf_obc_git_show_all_files
		if ((current_git_is_ref));then
			if ((current_fzf_multi));then
				current_fzf_opts+=" -m2"
			fi
			current_fzf_preview="${current_git_preview_ref}"
		fi
	fi
}

__fzf_obc_plugin_git_add_post() {
	__fzf_obc_load_plugin_config add
	#shellcheck disable=SC2154
	if ((current_enable));then
		if ((current_git_is_file));then
			__fzf_obc_git_add_files_status
			current_fzf_preview="${current_fzf_preview_file}"
		fi
	fi
}

