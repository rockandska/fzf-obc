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

@test '__fzf_obc::trap::add::all should success' {
	_filedir() {
		:
	}
	_filedir_xspec() {
		:
	}
	__fzf_obc::trap::function::_filedir() {
		:
	}
	__fzf_obc::trap::function::_filedir_xspec() {
		:
	}
	# bash_completion not loaded
	unset -f __fzf_obc::trap::function::_get_comp_words_by_ref || true
	run __fzf_obc::trap::add::all
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	run __fzf_obc::trap::add::all
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	local f
	for f in _filedir _filedir_xspec;do
		# check that thetrap is present
		declare -f "${f}" | grep $'trap \'__fzf_obc::trap::function::'"${f}"$' "$@"; trap - RETURN\' RETURN;'
		# check that trap was added only once
		[ $(declare -f "${f}" | grep $'__fzf_obc::trap::function::'"${f}" | wc -l) -eq 1 ]
	done
}
