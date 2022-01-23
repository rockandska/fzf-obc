#!/usr/bin/env bash

# shellcheck disable=SC2034
if [ -z "${BATS_PROJECT_DIR+x}" ];then
	1>&2 echo "Error: BATS_PROJECT_DIR is not set"
	return 1
fi

set -Eeuo pipefail

register_env() {
	printf -v "${1:-BATS_PREVIOUS_ENV}" '%s\n' "$(compgen -v | sort | while read -r var; do printf "%s=%q\n" "$var" "${!var:-}"; done)"
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
		exclude_paths
		path
		COLUMNS
		LINES
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

run_helper() {
	"$@"
}

run() {
	local origFlags
	origFlags="$(set +o); set -${-//c}"
	local origIFS="$IFS"
	local previous_trap
	printf -v "previous_trap" '%s\n' "$(trap)"
	local stdout_file stderr_file
	stdout_file=$(mktemp "${BATS_RUN_TMPDIR}/stdout.XXXXXX")
	stderr_file=$(mktemp "${BATS_RUN_TMPDIR}/stderr.XXXXXX")
	local rc
	trap 'rc=$?; trap - ERR;return 0' ERR
	run_helper "$@" 1> "${stdout_file}" 2> "${stderr_file}"
	eval "${previous_trap:-}"
	#shellcheck disable=SC2034
	status="${rc:-0}"
	local output_sep="${output_sep-$'\n'}"
	##### bats_stdout / bats_stdout_lines
	output=""
	lines=()
	bats_stdout=""
	bats_stdout_lines=()
	local line
	while IFS= read -r -d $'\n' line || [[ $line ]]; do
		printf -v  output "%s\n" "${output:-}${line}"
		printf -v  bats_stdout "%s\n" "${bats_stdout:-}${line}"
		bats_stdout_lines+=("${line}")
		lines+=("${line}")
	done < "${stdout_file:-}"
	bats_stdout="${bats_stdout%?}"
	##### bats_stderr / bats_stderr_lines
	bats_stderr=""
	bats_stderr_lines=()
	while IFS= read -r -d $'\n' line || [[ $line ]]; do
		printf -v  output "%s\n" "${output:-}${line}"
		printf -v  bats_stderr "%s\n" "${bats_stderr:-}${line}"
		bats_stderr_lines+=("${line}")
		lines+=("${line}")
	done < "${stderr_file:-}"
	bats_stderr="${bats_stderr%?}"
	output="${output%?}"
	#####
	IFS="$origIFS"
	eval "${origFlags}"
}

unset file
register_env
