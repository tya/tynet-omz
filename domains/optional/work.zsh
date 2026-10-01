# -*- mode: sh -*-
###############################################################################
# DOMAIN: work  —  OPT-IN. Not loaded unless activated.
#
# Activate on a machine:
#     mkdir -p ~/.config/tynet
#     echo work >> ~/.config/tynet/domains
#     exec zsh
#
# Deactivate: remove the `work` line from that file.
#
# Put work-only exports / aliases / functions / paths below. Keep anything
# with secrets out of git — source them from ~/.config/tynet/work.local.zsh:
###############################################################################

[[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/tynet/work.local.zsh" ]] && \
  source "${XDG_CONFIG_HOME:-$HOME/.config}/tynet/work.local.zsh"
