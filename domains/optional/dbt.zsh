# -*- mode: sh -*-
###############################################################################
# DOMAIN: dbt  —  OPT-IN. Not loaded unless activated.
#
# Activate on a machine:
#     mkdir -p ~/.config/tynet
#     echo dbt >> ~/.config/tynet/domains
#     exec zsh
#
# Deactivate: remove the `dbt` line from that file.
#
# Assumes dbt-core (and whichever adapter package) lives in a per-project
# venv, not globally — adapter versions are pinned per project and collide
# across projects otherwise. `dbtcd` below activates that venv on the way in.
###############################################################################

# ---------------------------------------------------------------------------
# exports
# ---------------------------------------------------------------------------
export DBT_PROFILES_DIR="${DBT_PROFILES_DIR:-$HOME/.dbt}"
# Skip the anonymous usage ping on every invocation.
export DBT_SEND_ANONYMOUS_USAGE_STATS=false

# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------
# pyenv, installed as an anyenv plugin (`anyenv install pyenv`) so it shares
# the same lazy-init shape as the goenv stub in 30-tools.zsh — shims go on
# PATH immediately, the slow `pyenv init` only runs the first time `pyenv`
# is actually invoked.
if [[ -d "$HOME/.anyenv/envs/pyenv" ]]; then
  export PYENV_ROOT="$HOME/.anyenv/envs/pyenv"
  path=( $PYENV_ROOT/bin $path $PYENV_ROOT/shims )
  pyenv() {
    unfunction pyenv
    eval "$(command pyenv init - zsh)"
    pyenv "$@"
  }
fi

# ---------------------------------------------------------------------------
# aliases
# ---------------------------------------------------------------------------
if command -v dbt &>/dev/null; then
  # dbt-core is a click app; this is click's built-in zsh-completion hook.
  # Cached like fzf/op/kubectl below — `dbt` import is slow, don't fork it
  # on every shell start.
  _tynet_cache_completion dbt env _DBT_COMPLETE=zsh_source dbt

  alias dbtr='dbt run'
  alias dbtt='dbt test'
  alias dbtb='dbt build'
  alias dbtc='dbt compile'
  alias dbtds='dbt docs generate && dbt docs serve'
  alias dbtde='dbt debug'
  alias dbtls='dbt ls'
  alias dbtseed='dbt seed'
  alias dbtfresh='dbt source freshness'
fi

# ---------------------------------------------------------------------------
# functions
# ---------------------------------------------------------------------------
# cd to the nearest ancestor dbt project (first dir up containing
# dbt_project.yml) and activate its ./.venv if one exists there.
dbtcd() {
  local dir=$PWD
  while [[ $dir != / ]]; do
    if [[ -f "$dir/dbt_project.yml" ]]; then
      cd "$dir" || return
      [[ -f "$dir/.venv/bin/activate" ]] && source "$dir/.venv/bin/activate"
      return
    fi
    dir=${dir:h}
  done
  echo "dbtcd: no dbt_project.yml found above $PWD" >&2
  return 1
}
