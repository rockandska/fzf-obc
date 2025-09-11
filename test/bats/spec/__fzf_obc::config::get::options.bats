load ../helpers/common.bash

setup() {
	[ ! -f ${BATS_PARENT_TMPNAME}.skip ] || skip "Error in previous test. Skip remaining tests"
	FZF_OBC_DISABLE=1 run source "${BATS_PROJECT_DIR}/bin/fzf-obc"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	assert_env_clean
}

teardown() {
	[ -n "$BATS_TEST_COMPLETED" ] || touch ${BATS_PARENT_TMPNAME}.skip
	if ! ((BATS_ERROR_STATUS));then
		assert_env_clean
	fi
}

@test "__fzf_obc::config::get::options should print options type" {
	local var
	run __fzf_obc::config::get::options var
	[ "$status" -eq 0 ]
	diff <(printf '%s\n' "${var[@]}") <(cat <<-EOF
		enable
		fzf_trigger
		fzf_multi
		fzf_opts
		fzf_binds
		fzf_height
		fzf_colors
		sort_opts
	EOF
	)
}
