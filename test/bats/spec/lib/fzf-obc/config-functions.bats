load ../../../helpers/common.bash

setup() {
	[ ! -f ${BATS_PARENT_TMPNAME}.skip ] || skip "Error in previous test. Skip remaining tests"
	run source "${BATS_PROJECT_DIR}/lib/fzf-obc/config-functions.bash"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	assert_env_clean
	run source "${BATS_PROJECT_DIR}/lib/fzf-obc/util-functions.bash"
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
	local i
	for i in "" "1" "ini";do
		local cfg_dir="${BATS_TEST_TMPDIR}/.config${i:-}/fzf-obc"
		# Config files for tests
		mkdir -p "${cfg_dir}/bob"
		touch "${cfg_dir}/bob/fail.cfg"
		mkdir -p "${cfg_dir}/plugins/kill"
		cat <<- EOF > "${cfg_dir}/default.cfg"
			std_fzf_trigger="default${i:-}"
		EOF
		cat <<- EOF > "${cfg_dir}/kill.cfg"
		std_fzf_trigger="kill${i:-}"

		std_filedir_colors=0
		EOF
		cat <<- EOF > "${cfg_dir}/plugins/default.cfg"
		std_fzf_trigger="plugins:default${i:-}"

		std_filedir_colors=0
		EOF
		cat <<- EOF > "${cfg_dir}/plugins/kill/default.cfg"
		std_fzf_trigger="plugins:kill:default${i:-}"

		std_filedir_colors=0
		EOF
		cat <<- EOF > "${cfg_dir}/plugins/kill/process.cfg"
		std_fzf_trigger="plugins:kill:process${i:-}"

		std_filedir_colors=0

		EOF

	done
	cat <<- EOF > "${BATS_TEST_TMPDIR}/.configini/fzf-obc/fzf-obc.ini"
		[git]
		std_fzf_trigger="-"

		[DEFAULT:plugins]
		std_fzf_trigger='*'
	EOF
}

@test "__fzf_obc_print_cfg2ini fail if parameters not correct" {
	run __fzf_obc_print_cfg2ini
	[ "$status" -eq 1 ]
	[ "$output" == "ERROR __fzf_obc_print_cfg2ini: One directory to convert needed" ]
	[ "${#lines[@]}" == 1 ]
	run __fzf_obc_print_cfg2ini mm mm
	[ "$status" -eq 1 ]
	[ "$output" == "ERROR __fzf_obc_print_cfg2ini: Only one directory to convert is allowed" ]
	[ "${#lines[@]}" == 1 ]
}

@test "__fzf_obc_print_cfg2ini fail if directory doesn't exist" {
	run __fzf_obc_print_cfg2ini "directory_not_found"
	[ "$status" -eq 1 ]
	[ "$output" == "ERROR __fzf_obc_print_cfg2ini: 'directory_not_found' doesn't exist or is not readable" ]
	[ "${#lines[@]}" == 1 ]
}

@test "__fzf_obc_print_cfg2ini return nothing if empty dir" {
	local config_ini
	run __fzf_obc_print_cfg2ini "/etc"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
}

@test "__fzf_obc_print_cfg2ini return the right ini" {
	local expected_output
	create_cfg_files4tests
	# check ini output
	run __fzf_obc_print_cfg2ini "${BATS_TEST_TMPDIR}/.config/fzf-obc"
	IFS= read -r -d '' expected_output <<- EOF || true
		[DEFAULT]
		std_fzf_trigger="default"
		[kill]
		std_fzf_trigger="kill"

		std_filedir_colors=0
		[DEFAULT:plugins]
		std_fzf_trigger="plugins:default"

		std_filedir_colors=0
		[kill:plugins]
		std_fzf_trigger="plugins:kill:default"

		std_filedir_colors=0
		[kill:plugins:process]
		std_fzf_trigger="plugins:kill:process"

		std_filedir_colors=0
	EOF
	diff <(echo "${output}") <(echo "$expected_output")
	unset config_ini
}

@test "__fzf_obc_print_ini_config fail without arguments" {
	local expected_output
	run __fzf_obc_print_ini_config
	read -r -d '' expected_output <<- EOF || true
		ERROR __fzf_obc_print_ini_config: At least one argument is requiered
		Usage :
		__fzf_obc_get_ini_config DIRECTORIES...
	EOF
	diff <(echo "$output") <(echo "$expected_output")
}

@test "__fzf_obc_print_ini_config print the right ini with only old config" {
	local expected_output
	create_cfg_files4tests
	run __fzf_obc_print_ini_config "${BATS_TEST_TMPDIR}/.config/fzf-obc" "${BATS_TEST_TMPDIR}/.config1/fzf-obc"
	IFS= read -r -d '' expected_output <<- EOF || true
		[DEFAULT]
		std_fzf_trigger="default"
		std_fzf_trigger="default1"
		[DEFAULT:plugins]
		std_fzf_trigger="plugins:default"

		std_filedir_colors=0
		std_fzf_trigger="plugins:default1"

		std_filedir_colors=0
		[kill]
		std_fzf_trigger="kill"

		std_filedir_colors=0
		std_fzf_trigger="kill1"

		std_filedir_colors=0
		[kill:plugins]
		std_fzf_trigger="plugins:kill:default"

		std_filedir_colors=0
		std_fzf_trigger="plugins:kill:default1"

		std_filedir_colors=0
		[kill:plugins:process]
		std_fzf_trigger="plugins:kill:process"

		std_filedir_colors=0
		std_fzf_trigger="plugins:kill:process1"

		std_filedir_colors=0
	EOF
	diff <(echo "$output") <(echo "$expected_output")
}

@test "__fzf_obc_print_ini_config print the right ini with a mix of old conf and ini" {
	local expected_output
	create_cfg_files4tests
	run __fzf_obc_print_ini_config "${BATS_TEST_TMPDIR}/.config/fzf-obc" "${BATS_TEST_TMPDIR}/.configini/fzf-obc" "${BATS_TEST_TMPDIR}/.config1/fzf-obc"
	IFS= read -r -d '' expected_output <<- EOF || true
		[DEFAULT]
		std_fzf_trigger="default"
		std_fzf_trigger="default1"
		[DEFAULT:plugins]
		std_fzf_trigger="plugins:default"

		std_filedir_colors=0
		std_fzf_trigger='*'
		std_fzf_trigger="plugins:default1"

		std_filedir_colors=0
		[git]
		std_fzf_trigger="-"

		[kill]
		std_fzf_trigger="kill"

		std_filedir_colors=0
		std_fzf_trigger="kill1"

		std_filedir_colors=0
		[kill:plugins]
		std_fzf_trigger="plugins:kill:default"

		std_filedir_colors=0
		std_fzf_trigger="plugins:kill:default1"

		std_filedir_colors=0
		[kill:plugins:process]
		std_fzf_trigger="plugins:kill:process"

		std_filedir_colors=0
		std_fzf_trigger="plugins:kill:process1"

		std_filedir_colors=0
	EOF
	diff <(echo "$output") <(echo "$expected_output")
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

@test "__fzf_obc_cfg_get" {
	local expected_var
	create_cfg_files4tests
	run source /dev/stdin <<<"$(__fzf_obc_print_cfg_func "${BATS_TEST_TMPDIR}/.config/fzf-obc" "${BATS_TEST_TMPDIR}/.config1/fzf-obc")"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	run __fzf_obc_cfg_get
	[ "$status" -eq 1 ]
	[ "$bats_stderr" == "ERROR __fzf_obc_cfg_get: __fzf_obc_cfg_get RETURN_VAR TRIGGER OPTION [cmd] [plugin]" ]
	run __fzf_obc_cfg_get ""
	[ "$status" -eq 1 ]
	[ "$bats_stderr" == "ERROR __fzf_obc_cfg_get: Missing 'return_var' parameter" ]
	run __fzf_obc_cfg_get a_var ""
	[ "$status" -eq 1 ]
	[ "$bats_stderr" == "ERROR __fzf_obc_cfg_get: Missing 'trigger' parameter" ]
	run __fzf_obc_cfg_get a_var std ""
	[ "$status" -eq 1 ]
	[ "$bats_stderr" == "ERROR __fzf_obc_cfg_get: Missing 'option' parameter" ]
	run __fzf_obc_cfg_get a_var "a" "test"
	[ "$status" -eq 1 ]
	[ "$bats_stderr" == "ERROR __fzf_obc_cfg_get: Unknown option 'a_test'" ]
	run __fzf_obc_cfg_get expected_var std fzf_trigger
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "$expected_var" == "default1" ]
	run __fzf_obc_cfg_get expected_var std fzf_trigger "unknown"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "$expected_var" == "default1" ]
	run __fzf_obc_cfg_get expected_var std fzf_trigger "unknown" "none"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "$expected_var" == "plugins:default1" ]
	run __fzf_obc_cfg_get expected_var std fzf_trigger "kill"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "$expected_var" == "kill1" ]
	run __fzf_obc_cfg_get expected_var std fzf_trigger "kill" "none"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "$expected_var" == "plugins:kill:default1" ]
	run __fzf_obc_cfg_get expected_var std fzf_trigger "kill" "process"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "$expected_var" == "plugins:kill:process1" ]
	FZF_OBC_STD_FZF_TMUX=3 run __fzf_obc_cfg_get expected_var std fzf_tmux
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "$expected_var" == "3" ]
	# add an ini file, cfg files should not be read anymore
	cat <<- 'EOF' > "${BATS_TEST_TMPDIR}/.config/fzf-obc/fzf-obc.ini"
		[DEFAULT]

		std_fzf_trigger='ini:default'

		[kill:plugins:process]

		std_fzf_trigger='ini:plugins:kill:process'
	EOF
	# reload
	run source /dev/stdin <<<"$(__fzf_obc_print_cfg_func "${BATS_TEST_TMPDIR}/.config1/fzf-obc" "${BATS_TEST_TMPDIR}/.config/fzf-obc")"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	run __fzf_obc_cfg_get expected_var std fzf_trigger
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "$expected_var" == "ini:default" ]
	run __fzf_obc_cfg_get expected_var std fzf_trigger "kill" "process"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "$expected_var" == "ini:plugins:kill:process" ]
}

@test "__fzf_obc_load_functions" {
	local HOME="${BATS_TEST_TMPDIR}"
	mkdir -p "${HOME}/.config/fzf-obc"
	mkdir -p "${HOME}/user_funcs"
	mkdir -p "${HOME}/user_funcs1"
	cat <<-EOF > "${HOME}/.config/fzf-obc/test.sh"
		xdg_test() {
			echo test
		}
	EOF
	cat <<-EOF > "${HOME}/user_funcs/test.sh"
		user_funcs_test() {
			echo test
		}
	EOF
	cat <<-EOF > "${HOME}/user_funcs1/test.sh"
		user_funcs1_test() {
			echo test
		}
	EOF
	run __fzf_obc_load_functions "${HOME}/.config/fzf-obc" "${HOME}/user_funcs" "${HOME}/user_funcs1"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	declare -f xdg_test
	declare -f user_funcs1_test
	declare -f user_funcs1_test
}

@test "__fzf_obc_detect_trigger" {
	local HOME="${BATS_TEST_TMPDIR}"
	local expected_value
	mkdir -p "${HOME}/.config/fzf-obc"
	cat <<-EOF > "${HOME}/.config/fzf-obc/fzf-obc.ini"
		[DEFAULT]
		std_fzf_trigger=''
		mlt_fzf_trigger='*'
		rec_fzf_trigger='**'
	EOF
	run source /dev/stdin <<<"$(__fzf_obc_print_cfg_func "${HOME}/.config/fzf-obc")"
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	run __fzf_obc_cfg_get expected_value mlt fzf_trigger
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "${expected_value}" == "*" ]
	local cur="/tmp*"
	local words=("ls" "/tmp*" "/etc*")
	local cword="1"
	local prev
	local current_cur current_words current_cword current_prev current_trigger_type
	run __fzf_obc_detect_trigger
	[ "$status" -eq 0 ]
	[ "$output" == "" ]
	[ "$cur" == "/tmp" ]
	[ "${words[1]}" == "/tmp" ]
	[ "${words[2]}" == "/etc*" ]
}
