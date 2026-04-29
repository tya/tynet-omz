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
  while IFS= read -r setup; do
    source "${setup}"
  done < <(find "${setups}" -iname "*.zsh" | sort)
}

# load personalize scripts
personalize

# remove duplicates from path
if typeset -f cleanpath > /dev/null; then
  cleanpath
fi
