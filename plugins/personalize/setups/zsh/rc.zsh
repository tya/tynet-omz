# -*- mode: sh -*-
#############################################################################
# FILE: rc.zsh
#
# This file loads Ty's global zsh run control.
#
#############################################################################

#############################################################################
# path setup
#############################################################################
if [ -d /opt/homebrew/opt/tpm/share/tpm ]; then
    export PATH=/opt/homebrew/opt/tpm/share/tpm:${PATH}
fi

if [ -d /usr/local/sbin ]; then
    export PATH=/usr/local/sbin:${PATH}
fi

if [ -d ${HOME}/bin ]; then
    export PATH=${HOME}/bin:${PATH}
fi

#############################################################################
# 1password setup
#############################################################################
if command -v op &> /dev/null; then
  eval "$(op completion zsh)"; compdef _op op
fi
