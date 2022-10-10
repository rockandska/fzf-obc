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

@test "__fzf_obc::trigger::detect should detect std trigger" {
	COMP_LINE='ls  '
	COMP_POINT='4'
	COMP_CWORD='1'
	COMP_WORDS=('ls' '')
	run __fzf_obc::trigger::detect
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "$current_trigger" == "std" ]
	[ "$current_trigger_size" -eq 0 ]
	unset COMP_LINE COMP_POINT COMP_CWORD COMP_WORDS current_trigger current_trigger_size current_cword_trigger_start_pos
}

#@test "__fzf_obc::trigger::detect should detect mlt trigger" {
#	local cur='/*'
#	local prev='ls'
#	local words=('ls' '/*')
#	local cword=1
#	local current_trigger
#	run __fzf_obc::trigger::detect
#	[ "$status" -eq 0 ]
#	[ "$output" == "" ]
#	[ "$current_trigger" == "mlt" ]
#	[ "$cur" == "/" ]
#	[ "${words[${cword}]}" == "/" ]
#}
#
#@test "__fzf_obc::trigger::detect should detect rec trigger" {
#	local cur='/**'
#	local prev='ls'
#	local words=('ls' '/**')
#	local cword=1
#	local current_trigger
#	run __fzf_obc::trigger::detect
#	[ "$status" -eq 0 ]
#	[ "$output" == "" ]
#	[ "$current_trigger" == "rec" ]
#	[ "$cur" == "/" ]
#	[ "${words[${cword}]}" == "/" ]
#}
