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

@test "__fzf_obc::config::get::default_config" {
	local var
	__fzf_obc::config::get::default_config var
	diff <(printf '%s\n' "${var}") <(cat <<-'EOF'
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
		rec_fzf_binds=("${mlt_fzf_binds[@]:-}")
	else
		rec_fzf_binds=("${std_fzf_binds[@]:-}")
	fi

	std_fzf_height=('--height' '40%')
	mlt_fzf_height=("${std_fzf_height[@]:-}")
	rec_fzf_height=("${std_fzf_height[@]:-}")

	std_fzf_colors=('--color' 'border:15')
	mlt_fzf_colors=("${std_fzf_colors[@]:-}")
	rec_fzf_colors=("${std_fzf_colors[@]:-}")

	std_sort_opts=()
	mlt_sort_opts=("${std_sort_opts[@]:-}")
	rec_sort_opts=("${std_sort_opts[@]:-}")
	EOF
	)
}
