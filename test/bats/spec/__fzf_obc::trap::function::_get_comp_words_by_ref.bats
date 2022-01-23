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

@test "__fzf_obc::trap::function::_get_comp_words_by_ref set the right variables" {
	run __fzf_obc::trap::function::_get_comp_words_by_ref
	cur=b
	prev=a
	words=(a b)
	cword=1
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	local v
	for v in cur prev words cword;do
		local v2="current_${v}"
		1>&2 echo "${v}"
		[ ! -z ${!v2+x} ]
		[ "${!v[*]}" == "${!v2[*]}" ]
		unset ${v2}
	done
	unset cur prev words cword
}
