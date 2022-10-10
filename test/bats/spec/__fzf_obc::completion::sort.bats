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

@test __fzf_obc::completion::sort default {
	local COMPREPLY=(bob BOB .git bob .git)
	run __fzf_obc::completion::sort < <(printf '%s\n' "${COMPREPLY[@]}")
	[ "$status" -eq 0 ]
	diff <(printf '%s\n' "${output}") <(cat <<-EOF
	.git
	BOB
	bob
	EOF
	)
}
