#!/usr/bin/env bash

# shellcheck disable=SC2034
if [ -z "${BATS_PROJECT_DIR+x}" ];then
	1>&2 echo "Error: BATS_PROJECT_DIR is not set"
	return 1
else
	set -Eeuo pipefail
fi

register_env() {
	printf -v "${1:-BATS_PREVIOUS_ENV}" '%s\n' "$(compgen -v | sort | while read -r var; do printf "%s=%q\n" "$var" "${!var:-}"; done)"
}

run_helper() {
	"$@"
}

run() {
	local origFlags
	origFlags="$(set +o); set -${-//c}"
	local origIFS="$IFS"
	local previous_trap
	printf -v "previous_trap" '%s\n' "$(trap)"
	local output_file stdout_file stderr_file
	output_file=$(mktemp "${BATS_RUN_TMPDIR}/output.XXXXXX")
	stdout_file=$(mktemp "${BATS_RUN_TMPDIR}/stdout.XXXXXX")
	stderr_file=$(mktemp "${BATS_RUN_TMPDIR}/stderr.XXXXXX")
	local rc
	trap 'rc=$?; trap - ERR;return 0' ERR
	{ { run_helper "$@" > >(tee "${stdout_file}" | cat); } 2> >(tee	"${stderr_file}" | cat); } &> "${output_file}"
	eval "${previous_trap:-}"
	#shellcheck disable=SC2034
	status="${rc:-0}"
	local output_sep="${output_sep-$'\n'}"
	##### output / lines
	output=""
	lines=()
	local line
	while IFS= read -r -d $'\n' line || [[ $line ]]; do
		printf -v output "%s\n" "${output}${line}"
		lines+=("${line}")
	done < "${output_file:-}"
	output="${output%?}"
	##### bats_stderr / bats_stderr_lines
	bats_stderr=""
	bats_stderr_lines=()
	while IFS= read -r -d $'\n' line || [[ $line ]]; do
		printf -v  bats_stderr "%s\n" "${bats_stderr:-}${line}"
		bats_stderr_lines+=("${line}")
	done < "${stderr_file:-}"
	bats_stderr="${bats_stderr%?}"
	##### bats_stdout / bats_stdout_lines
	bats_stdout=""
	bats_stdout_lines=()
	while IFS= read -r -d $'\n' line || [[ $line ]]; do
		printf -v  bats_stdout "%s" "${bats_stdout:-}${line}"
		bats_stdout_lines+=("${line}")
	done < "${stdout_file:-}"
	bats_stdout="${bats_stdout%?}"
	IFS="$origIFS"
	eval "${origFlags}"
}

assert_env_clean() {
	local _BATS_PREVIOUS_ENV
	register_env _BATS_PREVIOUS_ENV
	local pattern
	pattern=("$@")
	pattern+=(
		BASHPID
		"BASH_.*"
		"BATS_.*"
		"bats_.*"
		FUNCNAME
		LINENO
		lines
		output
		RANDOM
		SECONDS
		status
		"_.*"
	)
	local regex
	regex='^(declare -- .. )?('
	regex+=$(printf '|%s' "${pattern[@]}")
	regex+=')='
	local out
	if ! out=$(diff <(printf '%s\n' "${BATS_PREVIOUS_ENV:-}"  | grep -Ev "${regex}") <(printf '%s\n' "${_BATS_PREVIOUS_ENV}" | grep -Ev "${regex}"));then
		1>&2 printf -- '%s\n' '-----' 'Env is not clean, see diff bellow' '-----'
		1>&2 printf '%s\n' "$out"
		return 1
	fi
}

unset file
register_env
