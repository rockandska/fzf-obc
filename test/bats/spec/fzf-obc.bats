load ../helpers/common.bash

setup() {
	[ ! -f ${BATS_PARENT_TMPNAME}.skip ] || skip "Error in previous test. Skip remaining tests"
	assert_env_clean
}

teardown() {
	[ -n "$BATS_TEST_COMPLETED" ] || touch ${BATS_PARENT_TMPNAME}.skip
	if ! ((BATS_ERROR_STATUS));then
		assert_env_clean
	fi
}

@test "fzf-obc should works when sourced" {
	run source "${BATS_PROJECT_DIR}/bin/fzf-obc"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
}

@test "fzf-obc should print error if execute and not sourced" {
	run bash "${BATS_PROJECT_DIR}/bin/fzf-obc"
	[ "$status" -eq 1 ]
}
