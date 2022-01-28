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

@test "__fzf_obc::config::print::ini_config print the right ini" {
	local expected_output
	create_cfg_files4tests
	run __fzf_obc::config::print::ini_config "${BATS_TEST_TMPDIR}/.config/fzf-obc" "${BATS_TEST_TMPDIR}/.config/fzf-obc/plugins" "${BATS_TEST_TMPDIR}/.config/fzf-obc/plugins/subplugins"
	IFS= read -r -d '' expected_output <<- 'EOF' || true
	[DEFAULT]
	std_enable=1
	mlt_enable=1
	rec_enable=1

	std_fzf_trigger=''
	mlt_fzf_trigger='*'
	rec_fzf_trigger='**'

	std_fzf_multi=0
	mlt_fzf_multi=1
	rec_fzf_multi=1

	std_fzf_opts=('--select-1' '--exit-0' '--no-sort')
	mlt_fzf_opts=('--select-1' '--exit-0' '--no-sort')
	rec_fzf_opts=('--select-1' '--exit-0' '--no-sort')

	std_fzf_binds=('--bind' 'tab:accept')
	mlt_fzf_binds=('--bind' 'tab:toggle+down;shift-tab:toggle+up')
	if ((rec_fzf_multi));then
	rec_fzf_binds=("${mlt_fzf_binds[@]}")
	else
	rec_fzf_binds=("${std_fzf_binds[@]}")
	fi

	std_fzf_size=('40%')
	mlt_fzf_size=("${std_fzf_size[@]}")
	rec_fzf_size=("${std_fzf_size[@]}")

	std_fzf_position=('d')
	mlt_fzf_position=("${std_fzf_position[@]}")
	rec_fzf_position=("${std_fzf_position[@]}")

	std_fzf_tmux='1'
	mlt_fzf_tmux=("${std_fzf_tmux[@]}")
	rec_fzf_tmux=("${std_fzf_tmux[@]}")

	std_fzf_colors=('border:15')
	mlt_fzf_colors=("${std_fzf_colors[@]}")
	rec_fzf_colors=("${std_fzf_colors[@]}")

	std_sort_opts=('-V' '-d' '-f')
	mlt_sort_opts=("${std_sort_opts[@]}")
	rec_sort_opts=("${std_sort_opts[@]}")
	[DEFAULT:plugins]
	std_fzf_trigger='level2'
	std_fzf_trigger='level3'
	[git]
	std_fzf_trigger="level1"

	std_fzf_trigger="level2"

	[ls]
	sort_opts=(level1 level1)
	EOF
	diff <(echo -e "$output\n") <(echo -e "$expected_output")
}
