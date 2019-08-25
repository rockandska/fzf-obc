#!/usr/bin/env bash

_filedir()
{
  local IFS=$'\n'

  local cur="${cur}"
  __fzf_obc_tilde "${cur}" || return

  if [[ "$1" != -d ]]; then
    local xspec=${1:+"*.@($1|${1^^})"};
    __fzf_add2compreply < <(__fzf_obc_search "${cur}" "paths" "${xspec}")
    [[ -n ${COMP_FILEDIR_FALLBACK:-} && -n "$1" && ${#COMPREPLY[@]} -lt 1 ]] && __fzf_add2compreply < <(__fzf_obc_search "${cur}" "paths")
  else
    __fzf_add2compreply < <(__fzf_obc_search "${cur}" "dirs")
  fi

  if [[ "${#COMPREPLY[@]}" -gt 0 ]];then
    compopt -o filenames
  fi

  return 0
}

_filedir_xspec()
{
  local cur="${cur}"
  __fzf_obc_tilde "${cur%%\**}" || return
  local xspec
  # shellcheck disable=SC2154
  xspec="${_xspecs[${1##*/}]}"
  local matchop=!;
  if [[ $xspec == !* ]]; then
      xspec=${xspec#!};
      matchop=@;
  fi;
  xspec="$matchop($xspec|${xspec^^})";
  __fzf_add2compreply < <(__fzf_obc_search "${cur}" "paths" "${xspec}")

  if [[ "${#COMPREPLY[@]}" -gt 0 ]];then
    compopt -o filenames
  fi

  return 0
}
