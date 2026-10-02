# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A **framework-free zsh configuration**, sourced from `~/.zshrc` with a single line:

```zsh
source "$HOME/.tynet-omz/init.zsh"
```

It used to be an oh-my-zsh `ZSH_CUSTOM` plugin dir. oh-my-zsh was removed because it
dominated startup time (unoptimised `compinit` every shell + framework loader ≈ 1s).
There is no oh-my-zsh, no plugin manager, and no `ZSH_CUSTOM` anymore.

### Behavior changes from the oh-my-zsh era

Anything that looks like a regression against the old setup is probably one
of these intentional changes, not a bug:

- `docker-machine`'s alias is `dm`, not `mac` (`mac` was a footgun).
- `setup-displays` (air15 `displayplacer` layout) no longer runs at shell
  startup — it's autoloaded from `functions/` and must be invoked by hand.
- oh-my-zsh's implicit `setopt`s, keybindings, and ↑/↓ prefix-search are now
  declared explicitly in `domains/00-core.zsh` — if a default seems to have
  disappeared, it was probably an oh-my-zsh framework default that now needs
  an explicit line there.
- `~/.oh-my-zsh` is unreferenced and safe to delete once this lands alongside
  the companion `~/.zshrc` change in the `cg` dotfiles repo.

## Architecture

`init.zsh` is the entry point. In order it:

1. Returns unless the shell is interactive.
2. Sets `TYNET_HOME` (this repo, resolved from `${(%):-%x}`), and `TYNET_OS` /
   `OS` / `PLATFORM` / `ARCHITECTURE` from `$OSTYPE` and `$CPUTYPE` — **no `uname`
   subprocess**, and **before** any domain file (so an `aliases` section can read
   `$OS`, which the old layout could not).
3. Sources `lib/plugins.zsh` then `lib/compinit.zsh`.
4. Builds an ordered, de-duplicated list of `domains/*.zsh` (see below) and sources it.
5. Sources `lib/prompt.zsh`.
6. `typeset -U path PATH fpath FPATH` — de-dupes PATH keeping order (this replaced
   the old `cleanpath` function and its `awk` fork).
7. Calls `tynet_load_fsh` — fast-syntax-highlighting, which **must be last**.

`TYNET_PROFILE=1` wraps the whole thing in `zmodload zsh/zprof` … `zprof`.

### `lib/`

- **plugins.zsh** — prepends completion dirs to `fpath`
  (`$TYNET_BREW/share/zsh-completions`, `.../zsh/site-functions`,
  `$TYNET_HOME/functions`); `$TYNET_BREW` is hardcoded to `${HOMEBREW_PREFIX:-/opt/homebrew}`
  (no `brew --prefix` fork — `brew shellenv` runs in `~/.zprofile`). Defines
  `tynet_load_fsh`. Autoloads extensionless files in `functions/`.
- **compinit.zsh** — `compinit -C` (trust cache) unless the dump is missing or
  >24h old, in which case a full `compinit` runs and `touch`es the dump. Byte-compiles
  the dump to `.zwc` in the background when stale. Then completion `zstyle`s and a
  `COMPLETION_WAITING_DOTS` equivalent. Dump lives at
  `${XDG_CACHE_HOME:-~/.cache}/zsh/zcompdump-$ZSH_VERSION`.
- **prompt.zsh** — a direct, dependency-free port of the old oh-my-zsh `risto`
  theme: `$PROMPT` does `user@host:%2~ $(_tynet_git_prompt)%(!.#.$) `, and
  `_tynet_git_prompt` makes one `git status --porcelain` call (same cost as
  oh-my-zsh's `parse_git_dirty`) to print `‹branch›` with a trailing `*` if
  dirty, or nothing outside a git repo. No `vcs_info`, no oh-my-zsh theme
  system, no RPROMPT, no exit-status coloring — risto had none of those.

### `domains/`

One file per domain. Section order inside a file: `exports → shell options →
keybindings → PATH → aliases → functions` (not every file has every section).

Selection logic in `init.zsh`:

| Pattern | When |
|---|---|
| `domains/00-*.zsh`, `domains/20-*.zsh` | always |
| `domains/10-<os>.zsh` | `<os>` = `osx` or `linux` |
| `domains/optional/<name>.zsh` (or `optional/*-<name>.zsh`) | each bare `<name>` line in `~/.config/tynet/domains` |
| `domains/host/<shorthostname>.zsh` | if the file exists (loaded last) |

The top-level `domains/*.zsh(N)` glob does not recurse, so `optional/` and
`host/` are deliberately separate — they're only ever reached through the
opt-in config file or the hostname check, never by lexical order alone.
Within the top-level files, the numeric prefix controls load order (`00`
core, `10` OS, `20` personal, `30` tools).

Current domains: `00-core`, `10-osx`, `10-linux`, `20-personal`, `30-tools`
(always-on, top-level); `optional/work.zsh` (opt-in stub); `host/` (empty —
no per-machine override exists yet).

### `functions/`

Extensionless files, added to `fpath` and `autoload -Uz`'d by `lib/plugins.zsh`.
`setup-displays` (air15 `displayplacer` layout) lives here — defined, not run.

## Key Conventions

- Platform branches use `$TYNET_OS` (`osx` / `linux`). `$OS` is a kept alias.
- Guard optional tools with `command -v`. Make heavy inits lazy (see the `goenv`
  stub in `30-tools.zsh`) or cache their completion output via
  `_tynet_cache_completion` (writes `~/.cache/tynet/<tool>-completion.zsh`,
  refreshed when the binary is newer).
- Never add a `brew`, `op`, `kubectl`, `anyenv`, or similar subprocess to a code
  path that runs on every shell start — that is the class of cost this repo exists
  to avoid.
- fast-syntax-highlighting stays last (sourced by `init.zsh`, after PATH de-dupe).
- Use functions, not aliases, when positional args are needed.
- Single-quote aliases whose variables must expand at call time (`ppath`, `tya`).
- The `cg` function (`20-personal.zsh`) drives the bare-repo dotfiles workflow (`~/.cg/`).

## Testing changes

No build or test suite.

- **Full check:** `exec zsh` (or open a new terminal) — re-runs `init.zsh`
  end-to-end.
- **Startup cost:** `for i in $(seq 1 10); do /usr/bin/time zsh -i -c exit; done`
- **Profile:** `TYNET_PROFILE=1 zsh -i -c exit` — check nothing forks a subprocess
  per shell and `compinit` is single-digit ms on the second run.
- **Single file, fast loop:** `source domains/<file>.zsh` (skips ordering + the
  trailing PATH de-dupe / fsh load).
- After changes: `print -l $path` for duplicates / ordering; confirm guarded blocks
  no-op when the tool is absent, e.g.
  `env -i HOME=$HOME PATH=/usr/bin:/bin zsh -ic exit`.
- **Completion:** delete `~/.cache/zsh/zcompdump*`, start a shell, confirm it
  rebuilds and a `.zwc` appears; try `git che<Tab>`, `kubectl get po<Tab>`, `op <Tab>`.
