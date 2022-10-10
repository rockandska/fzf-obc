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


@test "__fzf_obc::trigger::clean should clean empty trigger" {
	COMP_LINE='ls  '
	COMP_POINT='4'
	COMP_CWORD='1'
	COMP_WORDS=('ls' '')
	__fzf_obc::trigger::clean ''
	[ "$COMP_LINE" == 'ls  ' ]
	[ "$COMP_POINT" == '4' ]
	[ "$COMP_CWORD" == '1' ]
	[ "${#COMP_WORDS[@]}" == '2' ]
	[ "${COMP_WORDS[$COMP_CWORD]}" == '' ]
	unset COMP_LINE COMP_POINT COMP_CWORD COMP_WORDS current_cword_trigger_start_pos
}

@test "__fzf_obc::trigger::clean should clean *** trigger" {
	COMP_LINE='ls  ***'
	COMP_POINT='7'
	COMP_CWORD='1'
	COMP_WORDS=('ls' '***')
	__fzf_obc::trigger::clean '***'
	[ "$COMP_LINE" == 'ls  ' ]
	[ "$COMP_POINT" == '4' ]
	[ "$COMP_CWORD" == '1' ]
	[ "${#COMP_WORDS[@]}" == '2' ]
	[ "${COMP_WORDS[$COMP_CWORD]}" == '' ]
	unset COMP_LINE COMP_POINT COMP_CWORD COMP_WORDS current_cword_trigger_start_pos
}

@test "__fzf_obc::trigger::clean should clean the right trigger if repeat" {
	COMP_LINE='ls  aa aa'
	COMP_POINT='9'
	COMP_CWORD='2'
	COMP_WORDS=('ls' 'aa' 'aa')
	__fzf_obc::trigger::clean 'aa'
	[ "$COMP_LINE" == 'ls  aa ' ]
	[ "$COMP_POINT" == '7' ]
	[ "$COMP_CWORD" == '2' ]
	[ "${#COMP_WORDS[@]}" == '3' ]
	[ "${COMP_WORDS[1]}" == 'aa' ]
	[ "${COMP_WORDS[$COMP_CWORD]}" == '' ]
	unset COMP_LINE COMP_POINT COMP_CWORD COMP_WORDS current_cword_trigger_start_pos
}

@test "__fzf_obc::trigger::clean should clean the right trigger if in the middle of himself" {
	COMP_LINE='ls  aa******aa'
	COMP_POINT='10'
	COMP_CWORD='1'
	COMP_WORDS=('ls' 'aa******aa')
	__fzf_obc::trigger::clean '**'
	[ "$COMP_LINE" == 'ls  aa****aa' ]
	[ "$COMP_POINT" == '8' ]
	[ "$COMP_CWORD" == '1' ]
	[ "${COMP_WORDS[$COMP_CWORD]}" == 'aa****aa' ]
	unset COMP_LINE COMP_POINT COMP_CWORD COMP_WORDS current_cword_trigger_start_pos
}
