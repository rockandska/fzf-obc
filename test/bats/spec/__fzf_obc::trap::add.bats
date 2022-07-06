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

@test '__fzf_obc::trap::add should not fail if function do not exists' {
	run __fzf_obc::trap::add _filedir
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
}

@test '__fzf_obc::trap::add should success if function exist' {
	_filedir() {
		: echo test
	}
	run __fzf_obc::trap::add _filedir
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	declare -f _filedir | grep $'trap \'__fzf_obc::trap::function::_filedir "$@"; trap - RETURN\' RETURN;'
	[ $(declare -f _filedir | grep $'__fzf_obc::trap::function::_filedir' | wc -l) -eq 1 ]
}
