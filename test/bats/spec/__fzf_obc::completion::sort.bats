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
	local current_trigger='std'
	run __fzf_obc::completion::sort
	1>&2 echo "$output"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	diff <(printf '%s\n' "${COMPREPLY[@]}") <(cat <<-EOF
	.git
	BOB
	bob
	EOF
	)
}

@test __fzf_obc::completion::sort should reflect sort_opts in config file {
	COMPREPLY=(bob BOB .git bob .git)
	local current_trigger='std'
	local current_cmd='ls'
	cat > "${BATS_TEST_TMPDIR}/fzf-obc.ini" <<-EOF
	[ls]
	std_sort_opts=('-V' '-d' '-f')
	EOF
	__fzf_obc::config::get::create "${BATS_TEST_TMPDIR}"
	run __fzf_obc::completion::sort
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	diff <(printf '%s\n' "${COMPREPLY[@]}") <(cat <<-EOF
	BOB
	bob
	.git
	EOF
	)
	unset COMPREPLY
}
