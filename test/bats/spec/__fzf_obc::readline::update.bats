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


@test "__fzf_obc::readline::update should update simple case" {
	COMP_LINE='ls t'
	COMP_POINT='4'
	COMP_CWORD='1'
	COMP_WORDS=('ls' 't')
	COMPREPLY=('test')
	current_cword_trigger_start_pos=4
	__fzf_obc::readline::update
	[[ "${COMP_LINE}" == 'ls test' ]]
	[[ "${COMP_POINT}" == '7' ]]
	[[ "${COMP_CWORD}" == '1' ]]
	[[ "${COMP_WORDS[*]}" == "ls test" ]]
	[[ "${COMPREPLY[0]}" == 'test' ]]
	[[ "${#COMPREPLY[@]}" == '1' ]]
	unset COMP_LINE COMP_POINT COMP_CWORD COMP_WORDS COMPREPLY current_cword_trigger_start_pos
}

@test "__fzf_obc::readline::update should more complex" {
	COMP_LINE='ls tt'
	COMP_POINT='4'
	COMP_CWORD='1'
	COMP_WORDS=('ls' 'tt')
	COMPREPLY=('test')
	current_cword_trigger_start_pos=4
	__fzf_obc::readline::update
	[[ "${COMP_LINE}" == 'ls testt' ]]
	[[ "${COMP_POINT}" == '7' ]]
	[[ "${COMP_CWORD}" == '1' ]]
	[[ "${COMP_WORDS[*]}" == "ls testt" ]]
	[[ "${COMPREPLY[0]}" == 'test' ]]
	[[ "${#COMPREPLY[@]}" == '1' ]]
	unset COMP_LINE COMP_POINT COMP_CWORD COMP_WORDS COMPREPLY current_cword_trigger_start_pos
}
