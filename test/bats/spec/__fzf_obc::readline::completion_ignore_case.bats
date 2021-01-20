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

@test "__fzf_obc::readline::completion_ignore_case should return 0 if off" {
	if [[ "${BASH_VERSINFO[0]}" -lt 4 ]];then
		skip "Can't use bind command without interactive shell with bash < 4"
	fi
	bind 'set completion-ignore-case off' 2> /dev/null
	run __fzf_obc::readline::completion_ignore_case
	[ "$status" -eq 1 ]
	[ "$output" == "" ]
}

@test "__fzf_obc::readline::completion_ignore_case should return 1 if on" {
	if [[ "${BASH_VERSINFO[0]}" -lt 4 ]];then
		skip "Can't use bind command without interactive shell with bash < 4"
	fi
	bind 'set completion-ignore-case on' 2> /dev/null
	run __fzf_obc::readline::completion_ignore_case
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
}
