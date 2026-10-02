# -*- mode: sh -*-
###############################################################################
# DOMAIN: personal  —  loaded on every host (not machine-specific, but mine).
###############################################################################

# ============================================================================
# dotfiles bare-repo helper
# ============================================================================
cg() { /usr/bin/git --git-dir="$HOME/.cg/" --work-tree="$HOME" "$@" }
alias cgs='cg status'

# Sitting at exactly $HOME, bare `git` targets the dotfiles repo instead of
# failing with "not a git repository" — everywhere else it's plain git.
# Safe from recursion: `command git` always resolves the real binary,
# bypassing this function (and any alias) regardless of $PWD.
git() {
  if [[ $PWD == "$HOME" ]]; then
    command git --git-dir="$HOME/.cg/" --work-tree="$HOME" "$@"
  else
    command git "$@"
  fi
}

# ============================================================================
# personal code directories
# ============================================================================
alias tya='cd $GOPATH/src/github.com/tya'
alias tynet94='cd $GOPATH/src/github.com/tynet94'
