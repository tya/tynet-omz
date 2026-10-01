# -*- mode: sh -*-
###############################################################################
#
# tynet-omz — framework-free zsh configuration loader
#
# Sourced from ~/.zshrc:
#     source "$HOME/.tynet-omz/init.zsh"
#
# Load order:
#   lib/plugins.zsh          fpath + third-party plugin helpers (before compinit)
#   lib/compinit.zsh         optimised completion system
#   domains/*.zsh            config, lexical order (see domain selection below)
#   domains/optional/*.zsh   only when named in ~/.config/tynet/domains
#   domains/host/<host>.zsh  only if the file exists (per-machine, loaded last)
#   lib/prompt.zsh           hand-rolled prompt
#   <PATH dedupe>            typeset -U  (replaces the old cleanpath function)
#   fast-syntax-highlighting sourced last (its own hard requirement)
#
###############################################################################

# interactive shells only
[[ -o interactive ]] || return

[[ -n $TYNET_PROFILE ]] && zmodload zsh/zprof

# absolute path to this repo, from the path of this very file
TYNET_HOME="${${(%):-%x}:A:h}"
export TYNET_HOME

###############################################################################
# OS detection — no `uname` subprocess.
#   $OS is the legacy name referenced by migrated config; keep it exported.
###############################################################################
case "$OSTYPE" in
  darwin*) TYNET_OS=osx    ; PLATFORM=Darwin ;;
  linux*)  TYNET_OS=linux  ; PLATFORM=Linux  ;;
  *)       TYNET_OS=unknown; PLATFORM="${OSTYPE}" ;;
esac
OS="$TYNET_OS"
ARCHITECTURE="$CPUTYPE"
export TYNET_OS OS PLATFORM ARCHITECTURE

###############################################################################
# Source everything, inside a scratch anon function so locals don't leak.
###############################################################################
() {
  local f name cfg
  local -a files main opt host

  files=(
    "$TYNET_HOME/lib/plugins.zsh"
    "$TYNET_HOME/lib/compinit.zsh"
  )

  # --- main domains: every domains/*.zsh, minus OS files for the wrong OS ------
  for f in "$TYNET_HOME"/domains/*.zsh(N); do
    case ${f:t} in
      *-osx.zsh|*-linux.zsh|*-darwin.zsh|*-unknown.zsh)
        [[ ${f:t} == *-${TYNET_OS}.zsh ]] && main+=( $f ) ;;
      *)
        main+=( $f ) ;;
    esac
  done
  main=( ${(o)main} )                       # lexical order by basename

  # --- opt-in domains: bare names (one per line) in ~/.config/tynet/domains ----
  #     e.g.  echo work >> ~/.config/tynet/domains
  cfg="${XDG_CONFIG_HOME:-$HOME/.config}/tynet/domains"
  if [[ -r $cfg ]]; then
    while IFS= read -r name; do
      [[ -z $name || $name == \#* ]] && continue
      opt+=( "$TYNET_HOME"/domains/optional/${name}.zsh(N)
             "$TYNET_HOME"/domains/optional/*-${name}.zsh(N) )
    done < $cfg
    opt=( ${(o)opt} )
  fi

  # --- per-host domain: domains/host/<shorthostname>.zsh ----------------------
  host=( "$TYNET_HOME/domains/host/${HOST%%.*}.zsh"(N) )

  files+=( $main $opt $host "$TYNET_HOME/lib/prompt.zsh" )

  for f in $files; do
    [[ -r $f ]] && source $f
  done
}

# de-dupe PATH/FPATH keeping first occurrence (replaces cleanpath + its awk fork)
typeset -U path PATH fpath FPATH

# syntax highlighting must be sourced last
(( $+functions[tynet_load_fsh] )) && tynet_load_fsh

[[ -n $TYNET_PROFILE ]] && zprof
