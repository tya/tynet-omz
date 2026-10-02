# -*- mode: sh -*-
###############################################################################
# FILE: lib/prompt.zsh
#
# Port of the "agnosterzak" oh-my-zsh theme:
#   https://github.com/zakaziko99/agnosterzak-ohmyzsh-theme
#
# A two-line Powerline-style prompt. Requires a Nerd/Powerline-patched font
# for the segment-separator arrow (U+E0B0) and branch icon (U+E0A0) —
# Ghostty is configured for "MesloLGS Nerd Font Mono" to supply them.
#
#   <blank line>
#   [✘][⚡][⚙] [time]  [cwd]  [git-branch + status]
#   [@user or user@host]
#
# Segments appear only when relevant (no git segment outside a repo, no
# status segment on a clean exit with no jobs, …) — same as upstream.
#
# No oh-my-zsh dependency:
#   - fg/fg_bold/fg_no_bold/reset_color are plain zsh (Functions/Misc/colors,
#     `autoload colors`), not an oh-my-zsh invention — oh-my-zsh's own
#     lib/theme-and-appearance.zsh calls the exact same autoload.
#   - parse_git_dirty is the one real oh-my-zsh function the theme calls;
#     reimplemented below as a plain dirty-check (same `git status
#     --porcelain --ignore-submodules=dirty` upstream uses by default).
#
# Deliberate deviations from upstream, both cosmetic-free:
#   - `$(uname)` → `$TYNET_OS` (already set by init.zsh) — saves an `uname`
#     fork on every single prompt render, not just shell startup.
#   - functions/vars are `_tynet_agnoster_*`-prefixed instead of upstream's
#     bare `prompt_*` / `CURRENT_BG` — avoids colliding with anything else
#     that defines a function or global by those common names.
#
# Cost note: unlike lib/compinit.zsh's "never fork per shell" rule, this
# prompt forks several subprocesses (git, ioreg/acpi, jobs) on *every*
# prompt render, not just once at shell startup — that's inherent to the
# agnoster design upstream, not a regression introduced here.
###############################################################################

setopt PROMPT_SUBST
autoload -Uz colors && colors

typeset -g _tynet_agnoster_bg='NONE'

# Segment-separator / status icons (Powerline-patched font required)
typeset -g _tynet_agnoster_sep=$''
typeset -g _tynet_agnoster_branch=$''
typeset -g _tynet_agnoster_cross=$'✘'
typeset -g _tynet_agnoster_lightning=$'⚡'
typeset -g _tynet_agnoster_gear=$'⚙'

# Dirty-check: upstream's parse_git_dirty, minus the oh-my-zsh config lookups
# (oh-my-zsh.hide-dirty / DISABLE_UNTRACKED_FILES_DIRTY) this repo never
# sets). Folded into _tynet_agnoster_git below — see the comment there.

### Segment drawing ###########################################################

_tynet_agnoster_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $_tynet_agnoster_bg != 'NONE' && $1 != $_tynet_agnoster_bg ]]; then
    print -n " %{$bg%F{$_tynet_agnoster_bg}%}$_tynet_agnoster_sep%{$fg%} "
  else
    print -n "%{$bg%}%{$fg%} "
  fi
  _tynet_agnoster_bg=$1
  [[ -n $3 ]] && print -n $3
}

_tynet_agnoster_end() {
  if [[ -n $_tynet_agnoster_bg ]]; then
    print -n " %{%k%F{$_tynet_agnoster_bg}%}$_tynet_agnoster_sep"
  else
    print -n "%{%k%}"
  fi
  print -n "%{%f%}"
  _tynet_agnoster_bg=''
}

### Segments ###################################################################

# user@hostname (full on SSH, just @user locally)
_tynet_agnoster_context() {
  if [[ -n "$SSH_CLIENT" ]]; then
    _tynet_agnoster_segment magenta white "%{$fg_bold[white]%(!.%{%F{white}%}.)%}$USER@%m%{$fg_no_bold[white]%}"
  else
    _tynet_agnoster_segment yellow magenta "%{$fg_bold[magenta]%(!.%{%F{magenta}%}.)%}@$USER%{$fg_no_bold[magenta]%}"
  fi
}

# Battery level (only drawn on battery power, i.e. unplugged)
_tynet_agnoster_battery() {
  local HEART=$'♥ '

  if [[ $TYNET_OS == osx ]]; then
    local smart_battery_status="$(ioreg -rc "AppleSmartBattery")"
    [[ $(grep -c '"ExternalConnected"[[:space:]]*=[[:space:]]*No' <<< "$smart_battery_status") -eq 1 ]] || return

    local maxcap currentcap pct
    maxcap=$(sed -n 's/^.*"MaxCapacity"[[:space:]]*=[[:space:]]*//p' <<< "$smart_battery_status")
    currentcap=$(sed -n 's/^.*"CurrentCapacity"[[:space:]]*=[[:space:]]*//p' <<< "$smart_battery_status")
    (( maxcap == 0 )) && return
    pct=$(( currentcap * 100 / maxcap ))

    if (( pct > 50 )); then
      _tynet_agnoster_segment green white
    elif (( pct > 20 )); then
      _tynet_agnoster_segment yellow white
    else
      _tynet_agnoster_segment red white
    fi
    print -n "%{$fg_bold[white]%}${HEART}${pct}%%%{$fg_no_bold[white]%}"

  elif [[ $TYNET_OS == linux && -d /sys/module/battery ]] && (( $+commands[acpi] )); then
    acpi 2>/dev/null | grep -q '^Battery.*Discharging' || return
    local pct
    pct=$(acpi | cut -f2 -d ',' | tr -cd '[:digit:]')

    if (( pct > 40 )); then
      _tynet_agnoster_segment green white
    elif (( pct > 20 )); then
      _tynet_agnoster_segment yellow white
    else
      _tynet_agnoster_segment red white
    fi
    print -n "%{$fg_bold[white]%}${HEART}${pct}%%%{$fg_no_bold[white]%}"
  fi
}

# Git: branch/detached head, dirty/clean, ahead/behind, stash, tag, file counts
#
# Perf: upstream (and an earlier version of this port) forked ~20
# subprocesses per render here — ~8ms per `git` call, ~5-6ms per `grep`
# call on this machine, measured at ~111ms for this segment alone. Two
# fixes bring that down to 7 `git` forks (8 when an upstream is
# configured — one more for the ahead/behind `log`) and zero `grep`/`wc`
# forks — measured at ~68ms with an upstream, same output:
#   - one `git status --porcelain` call feeds BOTH the dirty/clean check
#     (upstream forked a second, separate `git status` for this — see the
#     old _tynet_agnoster_git_dirty, now folded in below) and the file
#     counts, instead of two full `git status` invocations.
#   - the 7 `grep -c "^<pattern>"` calls that counted status-line types,
#     and the 2 more for ahead/behind, are replaced by a single zsh-native
#     loop over `${(f)git_status}` — zsh indexes strings for free, no fork.
#   - the no-longer-needed `git rev-parse --is-inside-work-tree` probe is
#     dropped; `git rev-parse --git-dir` already fails the same way
#     outside a repo, so checking its exit code covers both.
_tynet_agnoster_git() {
  # NB: `local repo_path=$(...) || return` would NOT work here — zsh (like
  # bash) reports the exit status of the `local` builtin itself for that
  # form, always 0, which silently swallows a failing command substitution.
  # Declaring first and assigning as a separate statement keeps `||`
  # looking at the actual exit status of `git rev-parse --git-dir`.
  local repo_path
  repo_path=$(command git rev-parse --git-dir 2>/dev/null) || return
  local ref clean mode bgclr fgclr
  local untracked added modified deleted tagged stashed ready_commit
  local to_push to_pull has_diverged

  # Single status call, used for both the dirty/clean decision (matching
  # oh-my-zsh's parse_git_dirty default of --ignore-submodules=dirty) and
  # the per-type file counts below.
  local git_status=$(command git status --porcelain --ignore-submodules=dirty 2>/dev/null)
  ref=$(command git symbolic-ref HEAD 2>/dev/null) || ref="➦ $(command git rev-parse --short HEAD 2>/dev/null)"

  if [[ -n $git_status ]]; then
    clean=''
    bgclr='yellow'; fgclr='magenta'
  else
    clean=' ✔'
    bgclr='green'; fgclr='white'
  fi

  local upstream=$(command git rev-parse --symbolic-full-name --abbrev-ref '@{upstream}' 2>/dev/null)
  local has_upstream=false
  [[ -n $upstream && $upstream != '@{upstream}' ]] && has_upstream=true

  local current_commit_hash=$(command git rev-parse HEAD 2>/dev/null)

  # One pass over the porcelain lines instead of 7 grep forks. Format is
  # "XY path" — X = index/staged status, Y = worktree status, "??" = untracked.
  local -i n_untracked=0 n_added=0 n_mod=0 n_modA=0 n_renA=0 n_del=0 n_delA=0
  local line x y
  for line in ${(f)git_status}; do
    [[ -z $line ]] && continue
    x=$line[1]; y=$line[2]
    if [[ $x == '?' && $y == '?' ]]; then
      (( n_untracked++ ))
      continue
    fi
    [[ $x == A ]] && (( n_added++ ))
    [[ $y == M ]] && (( n_mod++ ))
    [[ $x == M ]] && (( n_modA++ ))
    [[ $x == R ]] && (( n_renA++ ))
    [[ $y == D ]] && (( n_del++ ))
    [[ $x == D ]] && (( n_delA++ ))
  done

  (( n_untracked > 0 )) && untracked=" ${n_untracked}☀"
  (( n_added > 0 )) && added=" ${n_added}✚"

  if (( n_mod > 0 )); then
    modified=" ${n_mod}●"
    bgclr='red'; fgclr='white'
  fi
  if (( n_mod > 0 && n_modA > 0 )); then
    modified="$modified$((n_modA + n_renA))±"
  elif (( n_modA > 0 )); then
    modified=" ●$((n_modA + n_renA))±"
  fi

  if (( n_del > 0 )); then
    deleted=" ${n_del}‒"
    bgclr='red'; fgclr='white'
  fi
  if (( n_del > 0 && n_delA > 0 )); then
    deleted="$deleted$n_delA±"
  elif (( n_delA > 0 )); then
    deleted=" ‒$n_delA±"
  fi

  local tag_here=$(command git describe --exact-match --tags "$current_commit_hash" 2>/dev/null)
  [[ -n $tag_here ]] && tagged=" ☗$tag_here "

  # ${(f)...} splits on newlines; counting array elements needs no `wc` fork.
  local -a stash_lines=(${(f)"$(command git stash list -n1 2>/dev/null)"})
  local -i n_stash=${#stash_lines}
  if (( n_stash > 0 )); then
    stashed=" ${n_stash}⚙"
    bgclr='magenta'; fgclr='white'
  fi

  (( n_added > 0 || n_modA > 0 || n_delA > 0 )) && ready_commit=' ⚑'

  local upstream_prompt='' commits_ahead=0 commits_behind=0
  if [[ $has_upstream == true ]]; then
    local diff_line
    for diff_line in ${(f)"$(command git log --pretty=oneline --topo-order --left-right "${current_commit_hash}...${upstream}" 2>/dev/null)"}; do
      [[ $diff_line[1] == '<' ]] && (( commits_ahead++ ))
      [[ $diff_line[1] == '>' ]] && (( commits_behind++ ))
    done
    upstream_prompt=" ☊ "
  fi

  has_diverged=false
  (( commits_ahead > 0 && commits_behind > 0 )) && has_diverged=true
  if [[ $has_diverged == false ]] && (( commits_ahead > 0 )); then
    if [[ $bgclr == red || $bgclr == magenta ]]; then
      to_push=" $fg_bold[white]↑$commits_ahead$fg_bold[$fgclr]"
    else
      to_push=" $fg_bold[black]↑$commits_ahead$fg_bold[$fgclr]"
    fi
  fi
  [[ $has_diverged == false ]] && (( commits_behind > 0 )) && to_pull=" $fg_bold[magenta]↓$commits_behind$fg_bold[$fgclr]"

  if [[ -e "${repo_path}/BISECT_LOG" ]]; then
    mode=" <B>"
  elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
    mode=" >M<"
  elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" ]]; then
    mode=" >R>"
  fi

  _tynet_agnoster_segment $bgclr $fgclr
  print -n "%{$fg_bold[$fgclr]%}${ref/refs\/heads\//$_tynet_agnoster_branch $upstream_prompt}${mode}$to_push$to_pull$clean$tagged$stashed$untracked$modified$deleted$added$ready_commit%{$fg_no_bold[$fgclr]%}"
}

# Mercurial: rev@branch, dirty/clean (only draws if `hg` is installed and
# the cwd is inside an hg repo — guarded, so it's a silent no-op elsewhere)
_tynet_agnoster_hg() {
  (( $+commands[hg] )) || return
  command hg id >/dev/null 2>&1 || return

  local st rev branch
  rev=$(command hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
  branch=$(command hg id -b 2>/dev/null)
  if command hg st 2>/dev/null | grep -q '^\?'; then
    _tynet_agnoster_segment red black; st='±'
  elif command hg st 2>/dev/null | grep -q '^[MA]'; then
    _tynet_agnoster_segment yellow black; st='±'
  else
    _tynet_agnoster_segment green black
  fi
  print -n "☿ $rev@$branch $st"
}

# Current working directory
_tynet_agnoster_dir() {
  _tynet_agnoster_segment cyan white "%{$fg_bold[white]%}%~%{$fg_no_bold[white]%}"
}

# Active virtualenv, when its own prompt is suppressed
_tynet_agnoster_virtualenv() {
  local venv="$VIRTUAL_ENV"
  [[ -n $venv && -n $VIRTUAL_ENV_DISABLE_PROMPT ]] && _tynet_agnoster_segment blue black "($(basename "$venv"))"
}

_tynet_agnoster_time() {
  _tynet_agnoster_segment blue white "%{$fg_bold[white]%}%D{%a %e %b - %H:%M}%{$fg_no_bold[white]%}"
}

# Error / root / background-jobs indicator
_tynet_agnoster_status() {
  local -a symbols
  (( _tynet_agnoster_retval != 0 )) && symbols+="%{%F{red}%}$_tynet_agnoster_cross"
  (( UID == 0 )) && symbols+="%{%F{yellow}%}$_tynet_agnoster_lightning"
  (( $(jobs -l | wc -l) > 0 )) && symbols+="%{%F{cyan}%}$_tynet_agnoster_gear"
  [[ -n $symbols ]] && _tynet_agnoster_segment black default "$symbols"
}

### Build #######################################################################

_tynet_agnoster_build() {
  typeset -g _tynet_agnoster_retval=$?
  print -n "\n"
  _tynet_agnoster_status
  _tynet_agnoster_battery
  _tynet_agnoster_time
  _tynet_agnoster_virtualenv
  _tynet_agnoster_dir
  _tynet_agnoster_git
  _tynet_agnoster_hg
  _tynet_agnoster_end
  _tynet_agnoster_bg='NONE'
  print -n "\n"
  _tynet_agnoster_context
  _tynet_agnoster_end
}

PROMPT='%{%f%b%k%}$(_tynet_agnoster_build) '
