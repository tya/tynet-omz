# -*- mode: sh -*-
###############################################################################
# DOMAIN: core  —  loaded on every host, every OS, first.
#
# Merges what used to be zsh/{exports,aliases,functions,rc}.zsh plus the shell
# options / keybindings that oh-my-zsh used to provide.
###############################################################################

# ============================================================================
# exports
# ============================================================================
export EDITOR=vim
export LESS='-RFX'

# AWS
export SAM_CLI_TELEMETRY=0
export AWS_SESSION_TTL=12h
export AWS_ASSUME_ROLE_TTL=12h

# UniFi MCP
export UNIFI_POLICY_DELETE=false

# ============================================================================
# shell options  (previously supplied by oh-my-zsh lib/*)
# ============================================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS \
       HIST_IGNORE_SPACE HIST_VERIFY SHARE_HISTORY INC_APPEND_HISTORY

setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_MINUS
setopt ALWAYS_TO_END COMPLETE_IN_WORD INTERACTIVE_COMMENTS NO_BEEP
unsetopt FLOW_CONTROL

# ============================================================================
# keybindings  (terminfo-driven, with common fallbacks)
# ============================================================================
bindkey -e

if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  autoload -Uz add-zle-hook-widget
  _tynet_zle_smkx() { echoti smkx }
  _tynet_zle_rmkx() { echoti rmkx }
  add-zle-hook-widget line-init   _tynet_zle_smkx
  add-zle-hook-widget line-finish _tynet_zle_rmkx
fi

[[ -n ${terminfo[khome]} ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n ${terminfo[kend]}  ]] && bindkey "${terminfo[kend]}"  end-of-line
[[ -n ${terminfo[kdch1]} ]] && bindkey "${terminfo[kdch1]}" delete-char
[[ -n ${terminfo[kbs]}   ]] && bindkey "${terminfo[kbs]}"   backward-delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3;5~' kill-word
bindkey '^[[Z'    reverse-menu-complete

# type a prefix, press Up -> search history for it
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
[[ -n ${terminfo[kcuu1]} ]] && bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
[[ -n ${terminfo[kcud1]} ]] && bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# ============================================================================
# ESC ESC  ->  toggle `sudo ` / `sudoedit` on the current line  (was omz `sudo`)
# ============================================================================
_tynet_sudo_command_line() {
  [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
  if [[ $BUFFER == sudo\ * ]]; then
    LBUFFER="${LBUFFER#sudo }"
  elif [[ $BUFFER == ${EDITOR}\ * ]]; then
    LBUFFER="sudoedit ${LBUFFER#${EDITOR} }"
  elif [[ $BUFFER == sudoedit\ * ]]; then
    LBUFFER="${EDITOR} ${LBUFFER#sudoedit }"
  else
    LBUFFER="sudo $LBUFFER"
  fi
}
zle -N _tynet_sudo_command_line
bindkey -M emacs '\e\e' _tynet_sudo_command_line
bindkey -M viins '\e\e' _tynet_sudo_command_line
bindkey -M vicmd '\e\e' _tynet_sudo_command_line

# ============================================================================
# PATH
# ============================================================================
[[ -d /opt/homebrew/opt/tpm/share/tpm ]] && path=(/opt/homebrew/opt/tpm/share/tpm $path)
[[ -d /usr/local/sbin ]]                 && path=(/usr/local/sbin $path)
[[ -d $HOME/bin ]]                       && path=($HOME/bin $path)
[[ -d $HOME/.local/bin ]]                && path=($HOME/.local/bin $path)

# ============================================================================
# aliases — directory movement
# ============================================================================
alias up='cd ..; echo $PWD'
alias up2='cd ../..; echo $PWD'
alias up3='cd ../../..; echo $PWD'
alias up4='cd ../../../..; echo $PWD'
alias pd=pushd
alias pop=popd
alias dirs='dirs -v'

# aliases — program shortcuts
alias c=clear
alias h=history
alias l=less
alias m=more
alias so=source
alias ppath='echo $PATH | tr \: \\n'

# aliases — grep colour
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'

# aliases — typo insurance
alias chomd=chmod
alias suod=sudo
alias sudo='sudo '   # trailing space: let the next word be alias-expanded too

# aliases — vim / scm / git
alias lvim='vim -c set\ background=light'
alias rmorig='find . -type f -name "*.orig" -delete'
alias gf='git fetch --all'
alias gs='git st'
alias gl='git log -n 5'

# ============================================================================
# functions
# ============================================================================
lns()    { ln -s "$@" }
fndenv() { env | grep -i "$1" }
fndcmd() { history | grep -i "$1" }

# urlencode / urldecode  (was omz `urltools`; pure-zsh, ASCII bytes)
urlencode() {
  local i c str="$*" out=
  for (( i = 1; i <= ${#str}; i++ )); do
    c="${str[i]}"
    case "$c" in
      [a-zA-Z0-9.~_-]) out+="$c" ;;
      *)               out+=$(printf '%%%02X' "'$c") ;;
    esac
  done
  print -r -- "$out"
}
urldecode() {
  local str="${*//+/ }"
  printf '%b\n' "${str//\%/\\x}"
}
