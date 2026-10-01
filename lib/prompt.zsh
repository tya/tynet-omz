# -*- mode: sh -*-
###############################################################################
# FILE: lib/prompt.zsh
#
# Hand-rolled prompt (replaces the oh-my-zsh `risto` theme).
#
#   ───────────────────────────────────────────────────  2026-09-01 14:23:05
#   ty@air15  ~/src/tynet-omz  ‹master*›
#   ❯
#
# Line 1  full-width rule, right-aligned timestamp
# Line 2  user@host, cwd, git branch + dirty markers (info `risto` showed)
# Line 3  prompt char — green normally, red after a failed command
#
# If `check-for-changes` ever feels slow in a huge repo, disable it:
#   zstyle ':vcs_info:git:*' check-for-changes false
###############################################################################

setopt PROMPT_SUBST
zmodload zsh/datetime
autoload -Uz vcs_info add-zsh-hook

zstyle ':vcs_info:*'      enable git
zstyle ':vcs_info:git:*'  check-for-changes true
zstyle ':vcs_info:git:*'  unstagedstr  '*'
zstyle ':vcs_info:git:*'  stagedstr    '+'
zstyle ':vcs_info:git:*'  formats       '%b%u%c'
zstyle ':vcs_info:git:*'  actionformats '%b|%a%u%c'

typeset -g _tynet_git=''

_tynet_precmd() {
  vcs_info
  if [[ -n $vcs_info_msg_0_ ]]; then
    _tynet_git="  %F{red}‹${vcs_info_msg_0_}›%f"
  else
    _tynet_git=''
  fi

  local ts bar
  strftime -s ts '%Y-%m-%d %H:%M:%S' $EPOCHSECONDS
  local -i w=$(( COLUMNS - ${#ts} - 1 ))
  (( w < 0 )) && w=0
  bar="${(l:$w::─:)}"
  print -Pr -- "%F{240}${bar}%f ${ts}"
}
add-zsh-hook precmd _tynet_precmd

PROMPT='%F{green}%n@%m%f  %B%F{blue}%~%f%b${_tynet_git}
%(?.%F{green}.%F{red})%(!.#.❯)%f '
RPROMPT=''
