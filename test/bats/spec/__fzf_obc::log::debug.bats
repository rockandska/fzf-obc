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

@test "__fzf_obc::log::debug should not print if FZF_OBC_DEBUG not set" {
	run __fzf_obc::log::debug message
	[ "$status" -eq 0 ]
	[[ "$output" == '' ]]
}

@test "__fzf_obc::log::debug should print if FZF_OBC_DEBUG is set" {
	export FZF_OBC_LOG_PATH="/dev/stderr"
	FZF_OBC_DEBUG=1 run __fzf_obc::log::debug message
	[[ "$output" == ????'-'??'-'??' '??':'??':'??' - DEBUG -     |    |    |    | run_helper - message' ]]
	[[ "$bats_stderr" == ????'-'??'-'??' '??':'??':'??' - DEBUG -     |    |    |    | run_helper - message' ]]
	unset FZF_OBC_LOG_PATH
}
