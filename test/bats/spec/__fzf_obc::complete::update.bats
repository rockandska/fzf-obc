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

@test "__fzf_obc::complete::update should not fail if nothing to do" {
	run __fzf_obc::complete::update
	[ "$status" -eq 0 ]
}

@test "__fzf_obc::complete::update should update complete definitions and create wrappers" {
	complete -F _longopt ls
	run __fzf_obc::complete::update
	[ "$status" -eq 0 ]
	complete | grep -- 'complete -F __fzf_obc::complete::wrapper::_longopt ls'
	declare -f __fzf_obc::complete::wrapper::_longopt
}

@test "__fzf_obc::complete::update should do the same if run twice" {
	complete -F _longopt ls
	run __fzf_obc::complete::update
	[ "$status" -eq 0 ]
	complete | grep -- 'complete -F __fzf_obc::complete::wrapper::_longopt ls'
		run __fzf_obc::complete::update
	[ "$status" -eq 0 ]
	complete | grep -- 'complete -F __fzf_obc::complete::wrapper::_longopt ls'
	[ $(complete | wc -l) -eq 1 ]
}
