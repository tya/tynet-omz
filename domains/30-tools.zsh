# -*- mode: sh -*-
###############################################################################
# DOMAIN: tools  —  loaded on every host.
#
# Optional CLI integrations. Everything is guarded; heavy inits are lazy or
# cached to a file so a normal shell start pays ~nothing.
###############################################################################

# ---------------------------------------------------------------------------
# helper: source `<tool> completion zsh`, cached to a file, refreshed when the
# binary is newer than the cache.
# ---------------------------------------------------------------------------
_tynet_cache_completion() {
  local tool=$1; shift
  command -v "$tool" &>/dev/null || return
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/tynet/${tool}-completion.zsh"
  if [[ ! -s $cache || $commands[$tool] -nt $cache ]]; then
    mkdir -p "${cache:h}"
    "$@" >| "$cache" 2>/dev/null
  fi
  [[ -s $cache ]] && source "$cache"
}

# ============================================================================
# fzf  (replaces the oh-my-zsh `fzf` plugin; fzf >= 0.48)
#   cached to a file so a normal shell start doesn't fork `fzf`
# ============================================================================
_tynet_cache_completion fzf fzf --zsh

# ============================================================================
# 1Password CLI
# ============================================================================
if command -v op &>/dev/null; then
  _tynet_cache_completion op op completion zsh
  compdef _op op 2>/dev/null

  # Claude Code + UniFi MCP: op-resolved credentials for the unifi-network MCP.
  # --no-masking keeps claude's TTY detection working.
  [[ -f "$HOME/.config/unifi-mcp/.env" ]] && \
    alias claude-unifi='op run --no-masking --env-file "$HOME/.config/unifi-mcp/.env" -- claude'
fi

# ============================================================================
# kubectl
# ============================================================================
if command -v kubectl &>/dev/null; then
  _tynet_cache_completion kubectl kubectl completion zsh
  compdef _kubectl kubectl 2>/dev/null
  alias k=kubectl
fi

# ============================================================================
# goenv  (lazy — no `anyenv init` / `goenv rehash` at startup)
#   shims on PATH make `go` work immediately; first `goenv` call does full init.
# ============================================================================
if [[ -d "$HOME/.anyenv/envs/goenv" ]]; then
  export GOENV_ROOT="$HOME/.anyenv/envs/goenv"
  path=( $GOENV_ROOT/bin $path $GOENV_ROOT/shims )
  goenv() {
    unfunction goenv
    eval "$(command goenv init - zsh)"
    goenv "$@"
  }
fi

# ============================================================================
# httpie
# ============================================================================
if command -v http &>/dev/null; then
  alias https='http --default-scheme=https'
  alias jwt='http --default-scheme=https --auth-type jwt'
fi

# ============================================================================
# docker
# ============================================================================
command -v docker-compose &>/dev/null && alias doc='docker-compose'
command -v docker-machine &>/dev/null && alias dm='docker-machine'

# ============================================================================
# tmux  (handful of the oh-my-zsh `tmux` plugin aliases; no autostart)
# ============================================================================
if command -v tmux &>/dev/null; then
  alias ta='tmux attach -t'
  alias ts='tmux new-session -s'
  alias tl='tmux list-sessions'
  alias tksv='tmux kill-server'
fi

# ============================================================================
# colorize  (was omz `colorize`)
# ============================================================================
if command -v pygmentize &>/dev/null; then
  ccat()  { pygmentize -g "$@" }
  cless() { pygmentize -g "$@" | less -R }
fi
