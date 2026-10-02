# -*- mode: sh -*-
###############################################################################
# FILE: lib/prompt.zsh
#
# Prompt — ported from the oh-my-zsh `risto` theme
# (~/.oh-my-zsh/themes/risto.zsh-theme) plus its default dirty-marker setting
# (ZSH_THEME_GIT_PROMPT_DIRTY="*" / CLEAN="" in oh-my-zsh's
# lib/theme-and-appearance.zsh). Kept visually identical, no oh-my-zsh
# dependency:
#
#   ty@air15:src ‹master*› $
#
# user@host (green) : last two path components (bold blue), a single space,
# then ‹branch› in red with a trailing `*` if the tree is dirty — omitted
# entirely outside a git repo — then the prompt char (`$`, or `#` as root)
# in the terminal's default color. One line. No second line, no RPROMPT, no
# exit-status coloring: risto never had any of those.
###############################################################################

setopt PROMPT_SUBST

# Single git status call per prompt, same as oh-my-zsh's parse_git_dirty.
# GIT_OPTIONAL_LOCKS=0 avoids lock contention with other git processes,
# same guard oh-my-zsh's __git_prompt_git wrapper used.
_tynet_git_prompt() {
  local ref
  ref=$(GIT_OPTIONAL_LOCKS=0 command git symbolic-ref --short HEAD 2>/dev/null) \
    || ref=$(GIT_OPTIONAL_LOCKS=0 command git describe --tags --exact-match HEAD 2>/dev/null) \
    || ref=$(GIT_OPTIONAL_LOCKS=0 command git rev-parse --short HEAD 2>/dev/null) \
    || return

  local dirty=''
  [[ -n $(GIT_OPTIONAL_LOCKS=0 command git status --porcelain --ignore-submodules 2>/dev/null) ]] && dirty='*'

  print -n "%F{red}‹${ref//\%/%%}${dirty}›%f"
}

PROMPT='%F{green}%n@%m%f:%B%F{blue}%2~%f%b $(_tynet_git_prompt)%(!.#.$) '
