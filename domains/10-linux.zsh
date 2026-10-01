# -*- mode: sh -*-
###############################################################################
# DOMAIN: linux  —  loaded when $TYNET_OS == linux.
#
# The GNU-coreutils half of what used to be the `else` branch in
# zsh/aliases.zsh. Room here for apt / linuxbrew / systemd bits.
###############################################################################

# ============================================================================
# aliases — GNU ls
# ============================================================================
alias ls='ls -h --color=auto'
alias ll='ls -lh --color=auto'
alias la='ls -alh --color=auto'
alias lt='ls -lt --color=auto'
alias lll='ls -alh --color=auto | less'
alias llm='ls -alh --color=auto | more'
