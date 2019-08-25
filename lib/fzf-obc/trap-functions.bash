#!/usr/bin/env bash

__fzf_obc_trap__get_comp_words_by_ref() {
  : "${fzf_obc_is_glob:=0}"
  if [[ "${cur}" == *'**' ]];then
    fzf_obc_is_glob=1
    cur="${cur%\*\*}"
  fi
}
