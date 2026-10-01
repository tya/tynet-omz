# -*- mode: sh -*-
###############################################################################
# FILE: lib/plugins.zsh
#
# fpath wiring + third-party plugin helpers.
# Sourced BEFORE compinit so completion dirs are on fpath in time.
# No `brew` shell-out: the prefix is hardcoded (brew shellenv runs in ~/.zprofile).
###############################################################################

typeset -g TYNET_BREW="${HOMEBREW_PREFIX:-/opt/homebrew}"

# completion function directories (must precede compinit)
fpath=(
  $TYNET_BREW/share/zsh-completions(N)
  $TYNET_BREW/share/zsh/site-functions(N)
  "$TYNET_HOME/functions"(N)
  $fpath
)

# autoload extensionless function files dropped in functions/
if [[ -d "$TYNET_HOME/functions" ]]; then
  autoload -Uz "$TYNET_HOME"/functions/*(N.:t)
fi

###############################################################################
# fast-syntax-highlighting — invoked LAST by init.zsh via this helper.
# (Homebrew: `brew install zsh-fast-syntax-highlighting`.)
###############################################################################
tynet_load_fsh() {
  local f="$TYNET_BREW/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
  [[ -r $f ]] && source "$f"
}

# Optional: zsh-autosuggestions, if ever installed via brew.
if [[ -r "$TYNET_BREW/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$TYNET_BREW/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
