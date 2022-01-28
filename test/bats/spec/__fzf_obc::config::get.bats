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

@test "__fzf_obc::config::get should return default option value" {
	run __fzf_obc::config::get::create "${BATS_TEST_TMPDIR}"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	local current_fzf_trigger
	__fzf_obc::config::get current mlt fzf_trigger
	[ "${current_fzf_trigger}" == '*' ]
}

@test "__fzf_obc::config::get should return last default value found" {
	cat > "${BATS_TEST_TMPDIR}/fzf-obc.ini" <<-EOF
	[DEFAULT]
	mlt_fzf_trigger=0
	EOF
	run __fzf_obc::config::get::create "${BATS_TEST_TMPDIR}"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	local current_fzf_trigger
	__fzf_obc::config::get current mlt fzf_trigger
	[ "${current_fzf_trigger}" == '0' ]
}

@test "__fzf_obc::config::get should return env VAR value if set" {
	run __fzf_obc::config::get::create "${BATS_TEST_TMPDIR}"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	local current_fzf_trigger
	FZF_OBC_MLT_FZF_TRIGGER='ENV' __fzf_obc::config::get current mlt fzf_trigger
	[ "${current_fzf_trigger}" == 'ENV' ]
}

@test "__fzf_obc::config::get should return option value specific to command" {
	cat > "${BATS_TEST_TMPDIR}/fzf-obc.ini" <<-EOF
	[git]
	mlt_fzf_trigger=git
	EOF
	run __fzf_obc::config::get::create "${BATS_TEST_TMPDIR}"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	local current_fzf_trigger
	__fzf_obc::config::get current mlt fzf_trigger git
	[ "${current_fzf_trigger}" == 'git' ]
}

@test "__fzf_obc::config::get should return last value when hitting disable" {
	cat > "${BATS_TEST_TMPDIR}/fzf-obc.ini" <<-EOF
	[git]
	mlt_enable=0
	mlt_fzf_trigger=git
	EOF
	run __fzf_obc::config::get::create "${BATS_TEST_TMPDIR}"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	local current_fzf_trigger
	__fzf_obc::config::get current mlt fzf_trigger git
	[ "${current_fzf_trigger}" == '*' ]
}

@test "__fzf_obc::config::get should return nothing if disable globally" {
	run __fzf_obc::config::get::create "${BATS_TEST_TMPDIR}"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	local current_fzf_trigger
	FZF_OBC_DISABLE=1 __fzf_obc::config::get current mlt fzf_trigger git
	[ "${current_fzf_trigger:-}" == '' ]
}

@test "__fzf_obc::config::get should return nothing if disable by default config" {
	cat > "${BATS_TEST_TMPDIR}/fzf-obc.ini" <<-EOF
	[DEFAULT]
	mlt_enable=0
	mlt_fzf_trigger=git
	EOF
	run __fzf_obc::config::get::create "${BATS_TEST_TMPDIR}"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	local current_fzf_trigger
	__fzf_obc::config::get current mlt fzf_trigger git
	[ "${current_fzf_trigger:-}" == '' ]
}
