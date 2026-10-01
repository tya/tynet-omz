# -*- mode: sh -*-
###############################################################################
# DOMAIN: macos  —  loaded when $TYNET_OS == osx.
#
# Merges osx/{exports,aliases,functions,rc}.zsh.
###############################################################################

# ============================================================================
# exports
# ============================================================================
# solarized ls colours (BSD ls)
export LSCOLORS=exfxfeaeBxxehehbadacea

# ============================================================================
# aliases — BSD ls
# ============================================================================
alias ls='ls -hG'
alias ll='ls -lhG'
alias la='ls -alhG'
alias lt='ls -ltG'
alias lll='ls -alhG | less'
alias llm='ls -alhG | more'

# aliases — applications
[[ -d /Applications/SourceTree.app ]] && alias st='open -a SourceTree'

# ============================================================================
# command-not-found  (Homebrew tap; path hardcoded, no `brew` shell-out)
# ============================================================================
() {
  local h=/opt/homebrew/Library/Homebrew/command-not-found/handler.sh
  if [[ -r $h ]]; then
    export HOMEBREW_COMMAND_NOT_FOUND_HANDLER="$h"
    source "$h"
  fi
}

# ============================================================================
# Ghostty config editor -> MacVim
#   Ghostty's cmd+, hands its config file to the macOS default plain-text
#   handler, not $EDITOR. Point public.plain-text at MacVim.
#   Gated by a once-daily sentinel so re-launched shells pay nothing.
###############################################################################
() {
  local stamp="${XDG_CACHE_HOME:-$HOME/.cache}/tynet/duti-checked"
  [[ -n ${stamp}(Nmh-24) ]] && return          # checked < 24h ago
  command -v duti &>/dev/null || return
  [[ -d /Applications/MacVim.app ]] || return

  if [[ "$(duti -d public.plain-text 2>/dev/null)" != org.vim.MacVim ]]; then
    duti -s org.vim.MacVim public.plain-text all
  fi
  mkdir -p "${stamp:h}" && touch "$stamp"
}
