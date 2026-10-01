# -*- mode: sh -*-
###############################################################################
# FILE: lib/compinit.zsh
#
# Optimised completion init. The old setup ran a full `compinit` (security
# audit + dump rewrite) on every shell — ~730ms. Here:
#   * full audit + rebuild at most once per 24h
#   * otherwise trust the cached dump (`compinit -C`)
#   * byte-compile the dump in the background when stale
###############################################################################

autoload -Uz compinit

typeset -g _tynet_zcd="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
[[ -d ${_tynet_zcd:h} ]] || mkdir -p ${_tynet_zcd:h}

# non-empty only when the dump exists AND was modified < 24h ago
if [[ -n ${_tynet_zcd}(Nmh-24) ]]; then
  compinit -C -d "$_tynet_zcd"
else
  compinit -d "$_tynet_zcd"
  touch "$_tynet_zcd"
fi

# background byte-compile when the .zwc is missing or stale
if [[ ! -s ${_tynet_zcd}.zwc || ${_tynet_zcd} -nt ${_tynet_zcd}.zwc ]]; then
  zcompile -- "$_tynet_zcd" 2>/dev/null &!
fi

###############################################################################
# completion styling
###############################################################################
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*:warnings'     format '%F{red}-- no matches --%f'

###############################################################################
# COMPLETION_WAITING_DOTS equivalent (was set via oh-my-zsh)
###############################################################################
_tynet_complete_with_dots() {
  print -Pn '%F{red}…%f'
  zle expand-or-complete
  zle redisplay
}
zle -N _tynet_complete_with_dots
bindkey '^I' _tynet_complete_with_dots
