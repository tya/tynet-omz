# -*- mode: sh -*-
################################################################################
#
# ZSH Setup
#
################################################################################
# personalize zsh shell
personalize() {
  personalize_home="${ZSH_CUSTOM}/plugins/personalize"

  # source setups
  setups="${personalize_home}/setups"
  for setup in $(find "${setups}" -iname "*.zsh" | sort); do
    source "${setup}"
  done
}

# load personalize scripts
personalize

# remove duplicates from path
if typeset -f cleanpath > /dev/null; then
  cleanpath
fi
