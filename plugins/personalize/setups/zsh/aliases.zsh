# -*- mode: sh -*-
#############################################################################
# FILE: aliases.zsh
#
# This file loads Ty's personalized aliases
#
#############################################################################

#############################################################################
# Direcotry movement aliases
#############################################################################
alias up='cd ..; echo $PWD'
alias up2='cd ../..; echo $PWD'
alias up3='cd ../../..; echo $PWD'
alias up4='cd ../../../..; echo $PWD'

#############################################################################
# ls aliases
#############################################################################
if [[ "$OS" == 'osx' ]]; then
  alias ls="ls -hG"
  alias lll="ls -alhG | less"
  alias llm="ls -alhG | more"
  alias ll="ls -lhG"
  alias la="ls -alhG"
  alias lt="ls -ltG"
else
  alias ls="ls -h --color=auto"
  alias lll="ls -alh --color=auto | less"
  alias llm="ls -alh --color=auto | more"
  alias ll="ls -lh --color=auto"
  alias la="ls -alh --color=auto"
  alias lt="ls -lt --color=auto"
fi

#############################################################################
# Terminal aliases
#############################################################################
alias pd=pushd
alias pop=popd
alias so=source

#############################################################################
# Personal github code directories
#############################################################################
alias tya='cd $GOPATH/src/github.com/tya'
alias tynet94='cd $GOPATH/src/github.com/tynet94'

#############################################################################
# Program shortcut aliases
#############################################################################
alias c=clear
alias h=history
alias l=less
alias m=more
lns() { ln -s "$@"; }
alias dirs="dirs -v"
alias grep="grep --color"
alias egrep="egrep --color"
alias fgrep="fgrep --color"
alias ppath='echo $PATH | tr \: \\n'

#############################################################################
# Search aliases
#############################################################################
fndenv() { env | grep -i "$1"; }
fndcmd() { history | grep -i "$1"; }

#############################################################################
# Typo aliases
#############################################################################
alias chomd=chmod
alias suod=sudo

alias sudo="sudo "
#(recognize the space!)
# see http://serverfault.com/questions/61321/how-to-pass-alias-through-sudo
# manpage: A trailing space in value causes the next word to be checked for
#          alias substitution when the alias is expanded

#############################################################################
# Vim alias
#############################################################################
# light vim
alias lvim="vim -c set\ background=light"

#############################################################################
# scm aliases
#############################################################################
alias rmorig="find . -type f -name \"*.orig\" -delete"

#############################################################################
# git scm aliases
#############################################################################
alias gf="git fetch --all"
alias gs="git st"
alias gl="git log -n 5"

#############################################################################
# httpie aliases
#############################################################################
if command -v http &> /dev/null; then
  alias https='http --default-scheme=https'
  alias jwt='http --default-scheme=https --auth-type jwt'
fi

#############################################################################
# docker aliases
#############################################################################
if command -v docker-compose &> /dev/null; then
  alias doc="docker-compose"
fi
if command -v docker-machine &> /dev/null; then
  alias mac="docker-machine"
fi

#############################################################################
# cfg dotfile shortcut
#############################################################################
cg() { /usr/bin/git --git-dir=$HOME/.cg/ --work-tree=$HOME "$@"; }
alias cgs='cg status'
