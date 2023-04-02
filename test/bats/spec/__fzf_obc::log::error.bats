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

@test "__fzf_obc::log::error should print correctly" {
	export FZF_OBC_LOG_PATH="/dev/stderr"
	run __fzf_obc::log::error message
	[ "$status" -eq 1 ]
	[[ "$output" == ????'-'??'-'??' '??':'??':'??' - ERROR -     |    |    |    | run_helper - message' ]]
	[[ "$bats_stderr" == ????'-'??'-'??' '??':'??':'??' - ERROR -     |    |    |    | run_helper - message' ]]
	unset FZF_OBC_LOG_PATH
}
