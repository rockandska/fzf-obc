# Bash functions for Makefile shell

cmdsexists() {
  local cmds
  IFS=' ' read -r -a cmds <<< "${1:-}"
  local where="${2:-}"
  local result
  for cmd in "${cmds[@]}";do
    if ! result="$(command -v ${cmd})";then
      1>&2 echo "'$cmd' was not found"
      return 1
    fi
    if [[ -n "${where:-}" ]];then
      if [[ $result == $where/$cmd ]];then
        1>&2 echo "'$cmd' found in '$result'"
      else
        1>&2 echo "'$cmd' was not found in '${where}' but in '${result}'"
        return 1
      fi
    fi
  done
}
