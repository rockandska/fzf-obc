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

@test "__fzf_obc::completion::longestprefix should set correct prefix when ignore_case is off" {
	if [[ "${BASH_VERSINFO[0]}" -lt 4 ]];then
		# Can't use bind command without interactive shell with bash < 4
		__fzf_obc::readline::completion_ignore_case() {
			return 1
		}
	else
		bind 'set completion-ignore-case off' 2> /dev/null
	fi
	local current_cword_trigger_start_pos=0
	local prefix
	local COMPREPLY=("test/bats/spec/__fzf_obc::log::debug.bats" "test/bats/spec/fzf-obc.bats" "test/bats/spec/__fzf_obc::log::debug::var.bats")
	run __fzf_obc::completion::longestprefix prefix
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "${#COMPREPLY[@]}" -eq 3 ]
	[ "${prefix}" == "test/bats/spec/" ]
}

@test "__fzf_obc::completion::longestprefix should set correct prefix when ignore_case is on" {
	if [[ "${BASH_VERSINFO[0]}" -lt 4 ]];then
		# Can't use bind command without interactive shell with bash < 4
		__fzf_obc::readline::completion_ignore_case() {
			return 0
		}
	else
		bind 'set completion-ignore-case on' 2> /dev/null
	fi
	local current_cword_trigger_start_pos=0
	local prefix
	local COMPREPLY=(abcd abc aB)
	run __fzf_obc::completion::longestprefix prefix
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "${#COMPREPLY[@]}" -eq 3 ]
	[ "${prefix}" == "ab" ] || [ "${prefix}" == "aB" ]
}
