#!/usr/bin/env bash

__fzf_obc_post__completion_loader() {
  __fzf_obc_update_complete || return $?
}

__fzf_obc_post_kill() {
  local IFS=$'\n'
  # shellcheck disable=SC2034
  local cur prev words cword _
  _get_comp_words_by_ref -n "<>&" cur prev words cword;
  case $prev in
    -s|-l)
      return 0
      ;;
  esac;
  if [[ $cword -eq 1 && "$cur" == -* ]]; then
    return 0
  else
    # Only surcharged if it is not an option
    read -r -d '' -a COMPREPLY < <(
      command ps -ef \
      | sed 1d \
      | tr '\n' '\0' \
      | FZF_DEFAULT_OPTS="--height ${FZF_OBC_HEIGHT} --min-height 15 --reverse $FZF_DEFAULT_OPTS --preview 'echo {}' --preview-window down:3:wrap $FZF_COMPLETION_OPTS -m" \
        __fzf_obc_cmd \
      | tr '\0' '\n' \
      | awk '{print $2}' \
      | tr '\n' ' ' \
      | sed 's/ $//'
    )
    printf '\e[5n'
    return 0
  fi
}
