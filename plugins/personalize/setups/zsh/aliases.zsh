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
alias up="cd ..; echo $PWD"
alias up2="cd ../..; echo $PWD"
alias up3="cd ../../..; echo $PWD"
alias up4="cd ../../../..; echo $PWD"

#############################################################################
# ls aliases
#############################################################################
alias ls="ls -hG"
alias lll="ls -alhG | less"
alias llm="ls -alhG | more"
alias ll="ls -lhG"
alias la="ls -alhG"
alias lt="ls -ltG"

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
lns() { ln -s "$1"; }
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
alias https='http --default-scheme=https'
alias jwt='http --default-scheme=https --auth-type jwt'

#############################################################################
# docker aliases
#############################################################################
alias doc="docker-compose"
alias mac="docker-machine"

#############################################################################
# cfg dotfile shortcut
#############################################################################
alias cg='/usr/bin/git --git-dir=$HOME/.cg/ --work-tree=$HOME'
alias cgs='cg status'
