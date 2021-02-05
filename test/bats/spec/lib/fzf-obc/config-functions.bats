load ../../../helpers/common.bash

setup() {
	[ ! -f ${BATS_PARENT_TMPNAME}.skip ] || skip "Error in previous test. Skip remaining tests"
	run source "${BATS_PROJECT_DIR}/lib/fzf-obc/config-functions.bash"
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

create_cfg_files4tests() {
	BATS_TEST_TMPDIR=$(mktemp -d bats-XXXXXX)
	# Config files for tests
	mkdir -p "${BATS_TEST_TMPDIR}/.config/fzf-obc/bob/"
	touch "${BATS_TEST_TMPDIR}/.config/fzf-obc/bob/fail.cfg"
	mkdir -p "${BATS_TEST_TMPDIR}/.config/fzf-obc/plugins/kill"
	cat <<- EOF > "${BATS_TEST_TMPDIR}/.config/fzf-obc/default.cfg"
		std_fzf_trigger='default'
	EOF
	cat <<- EOF > "${BATS_TEST_TMPDIR}/.config/fzf-obc/kill.cfg"
	std_fzf_trigger='kill'

	std_filedir_colors=0
	EOF
	cat <<- EOF > "${BATS_TEST_TMPDIR}/.config/fzf-obc/plugins/default.cfg"
	std_fzf_trigger='plugins:default'

	std_filedir_colors=0
	EOF
	cat <<- EOF > "${BATS_TEST_TMPDIR}/.config/fzf-obc/plugins/kill/default.cfg"
	std_fzf_trigger='plugins:kill:default'

	std_filedir_colors=0
	EOF
	cat <<- EOF > "${BATS_TEST_TMPDIR}/.config/fzf-obc/plugins/kill/process.cfg"
	std_fzf_trigger='plugins:kill:process'

	std_filedir_colors=0

	EOF
}

@test "__fzf_obc_cfg2ini" {
	local config_ini
	local expected_output
	# with non existent directory
	run __fzf_obc_cfg2ini "directory_not_found" "config_ini"
	[ "$status" -eq 1 ]
	[ "$output" == "'directory_not_found' doesn't exist or is not readable" ]
	[ "${#lines[@]}" == 1 ]
	create_cfg_files4tests
	# check ini output
	export LC_COLLATE=C
	run __fzf_obc_cfg2ini "${BATS_TEST_TMPDIR}/.config/fzf-obc" "config_ini"
	read -r -d '' expected_output <<- EOF || true
		[default]
		std_fzf_trigger='default'
		[kill]
		std_fzf_trigger='kill'

		std_filedir_colors=0
		[plugins:default]
		std_fzf_trigger='plugins:default'

		std_filedir_colors=0
		[plugins:kill:default]
		std_fzf_trigger='plugins:kill:default'

		std_filedir_colors=0
		[plugins:kill:process]
		std_fzf_trigger='plugins:kill:process'

		std_filedir_colors=0
	EOF

	[ "${config_ini}" == "$expected_output" ]
	unset config_ini
	unset LC_COLLATE
}

@test "__fzf_obc_print_cfg_func" {
	# Missing parameter
	run __fzf_obc_print_cfg_func
	[ "$status" -eq 1 ]
	[ "${bats_stderr_lines[0]}" == 'At least one directory where to search configuration is required' ]
	create_cfg_files4tests
	# run with cfg files
	run __fzf_obc_print_cfg_func "${BATS_TEST_TMPDIR}/.config/fzf-obc"
	[ "$status" -eq 0 ]
	[ "$bats_stderr" == "" ]
	[ "$bats_stdout" != "" ]
}

@test "__fzf_cfg_get" {
	create_cfg_files4tests
	run source /dev/stdin <<<"$(__fzf_obc_print_cfg_func "${BATS_TEST_TMPDIR}/.config/fzf-obc")"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	run __fzf_obc_cfg_get
	[ "$status" -eq 1 ]
	[ "$bats_stderr" == "__fzf_obc_cfg_get TRIGGER OPTION [cmd] [plugin]" ]
	run __fzf_obc_cfg_get ""
	[ "$status" -eq 1 ]
	[ "$bats_stderr" == "__fzf_obc_cfg_get : Missing 'trigger' parameter" ]
	run __fzf_obc_cfg_get std ""
	[ "$status" -eq 1 ]
	[ "$bats_stderr" == "__fzf_obc_cfg_get : Missing 'option' parameter" ]
	run __fzf_obc_cfg_get "a" "test"
	[ "$status" -eq 1 ]
	[ "$bats_stderr" == "__fzf_obc_cfg_get : Unknown option : 'a_test'" ]
	run __fzf_obc_cfg_get std fzf_trigger
	[ "$status" -eq 0 ]
	[ "$output" == "default" ]
	run __fzf_obc_cfg_get std fzf_trigger "unknown"
	[ "$status" -eq 0 ]
	[ "$output" == "default" ]
	run __fzf_obc_cfg_get std fzf_trigger "kill"
	[ "$status" -eq 0 ]
	[ "$output" == "kill" ]
	run __fzf_obc_cfg_get std fzf_trigger "kill" "process"
	[ "$status" -eq 0 ]
	[ "$output" == "plugins:kill:process" ]
	FZF_OBC_STD_FZF_TMUX=3 run __fzf_obc_cfg_get std fzf_tmux
	[ "$status" -eq 0 ]
	[ "$output" == "3" ]
	# add an ini file, cfg files should not be read anymore
	cat <<- 'EOF' > "${BATS_TEST_TMPDIR}/.config/fzf-obc/fzf-obc.ini"
		[default]

		std_fzf_trigger='ini:default'

		[plugins:kill:process]

		std_fzf_trigger='ini:plugins:kill:process'
	EOF
	# reload
	run source /dev/stdin <<<"$(__fzf_obc_print_cfg_func "${BATS_TEST_TMPDIR}/.config/fzf-obc")"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	run __fzf_obc_cfg_get std fzf_trigger
	[ "$status" -eq 0 ]
	[ "$output" == "ini:default" ]
	run __fzf_obc_cfg_get std fzf_trigger "kill" "process"
	[ "$status" -eq 0 ]
	[ "$output" == "ini:plugins:kill:process" ]
}
