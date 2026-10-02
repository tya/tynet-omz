# tynet-omz

Framework-free zsh configuration. Formerly an [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
`ZSH_CUSTOM` dir; oh-my-zsh has been removed for startup speed (~580ms → well under
100ms). Completion, keybindings, and the prompt are now provided directly.

## Setup

`~/.zshrc` only needs:

```zsh
[[ -d "$HOME/.tynet-omz" ]] || git clone https://github.com/tya/tynet-omz "$HOME/.tynet-omz"
source "$HOME/.tynet-omz/init.zsh"
```

Homebrew's environment must be set before this runs — keep
`eval "$(/opt/homebrew/bin/brew shellenv)"` in `~/.zprofile` (login shells).

Recommended Homebrew packages:

```
brew install zsh-fast-syntax-highlighting zsh-completions fzf
# optional: brew install zsh-autosuggestions displayplacer duti
```

## Layout

```
init.zsh              entry point: OS detection, ordered sourcing, PATH de-dupe
lib/
  plugins.zsh         fpath wiring + fast-syntax-highlighting helper (no `brew` fork)
  compinit.zsh        completion system: daily audit, cached dump, async zcompile
  prompt.zsh          prompt — ported from oh-my-zsh's agnosterzak theme
domains/
  00-core.zsh         every host: shell opts, keybindings, aliases, functions, PATH
  10-osx.zsh          $TYNET_OS == osx: BSD ls, command-not-found, Ghostty→MacVim
  10-linux.zsh        $TYNET_OS == linux: GNU ls
  20-personal.zsh     every host: dotfiles `cg`, personal cd aliases
  30-tools.zsh        every host: fzf, op, kubectl, goenv (lazy), docker, tmux, …
  optional/           opt-in only (see below) — e.g. optional/work.zsh
  host/               per-machine overrides (see below), empty until you add one
functions/            extensionless files, autoloaded via fpath (e.g. setup-displays)
```

### Domain selection

`init.zsh` sources, in lexical order:

- `domains/00-*.zsh` and `domains/20-*.zsh` — always
- `domains/10-<os>.zsh` — where `<os>` is `osx` or `linux`
- `domains/optional/<name>.zsh` (or `optional/*-<name>.zsh`) — for each bare
  `<name>` listed (one per line) in `~/.config/tynet/domains`.
  Example: `echo work >> ~/.config/tynet/domains`
- `domains/host/<shorthostname>.zsh` — if present, loaded last (per-machine
  overrides). `<shorthostname>` is `$HOST` with everything after the first
  `.` stripped, e.g. `air15` for `air15.local`. The directory exists but is
  empty by default — nothing loads from it until you add a file.

Add a new always-on domain by dropping a `NN-name.zsh` file directly in
`domains/`. Use a numeric prefix to place it in load order (`00` core → `30`
tools; pick `20`–`30` for most). Add a new opt-in domain under
`domains/optional/` instead — see `optional/work.zsh` for the pattern
(including how to keep secrets out of git via a `*.local.zsh` include).

## Conventions

- One file per domain, sectioned `exports → shell options → keybindings →
  PATH → aliases → functions`.
- Platform branches use `$TYNET_OS` (`osx` / `linux`); `$OS` is kept as a legacy
  alias. Both are set in `init.zsh` **before** any domain loads, so unlike the old
  layout they are safe to read in an `aliases` section.
- Optional tools are guarded with `command -v`. Heavy inits are lazy (`goenv`) or
  cached to `~/.cache/tynet/<tool>-completion.zsh`.
- fast-syntax-highlighting is sourced **last**, by `init.zsh`, after PATH de-dupe.
- `TYNET_PROFILE=1 zsh -i -c exit` prints a `zprof` report.

## Prompt

A dependency-free port of the oh-my-zsh
[agnosterzak](https://github.com/zakaziko99/agnosterzak-ohmyzsh-theme) theme —
a two-line Powerline-style prompt:

```
<blank line>
[✘ error][⚡ root][⚙ jobs]  [🔋 battery]  [time]  [cwd]  [git branch + status]
[@user, or user@host over SSH]
```

Each segment shows only when relevant — no git segment outside a repo, no
battery segment on AC power, no status segment on a clean exit with no
background jobs. Requires a **Nerd/Powerline-patched font** for the
segment-separator arrow and branch icon; Ghostty is set to
`MesloLGS Nerd Font Mono` for this (see the `cg` dotfiles repo).

Unlike the rest of this repo, this prompt forks several subprocesses
(`git`, `ioreg`/`acpi`, `jobs`) on every render, not just once at shell
startup — that's inherent to the upstream theme's design, not something
introduced here.

## Migrating from oh-my-zsh

Behavior changes to expect the first time you switch over:

- **`dm` replaces `docker-machine`'s `mac` alias.** `mac` was a footgun (too
  close to typing an actual hostname); `command -v docker-machine` still guards it.
- **`setup-displays` no longer runs at startup.** It's an autoloaded function
  now (`functions/setup-displays`) — run it by hand when you want the air15
  `displayplacer` layout applied, instead of it firing on every new shell.
- **Shell options and keybindings are explicit, not implicit.** oh-my-zsh set
  a bunch of these (history dedup, `AUTO_CD`, `AUTO_PUSHD`, emacs keybindings,
  ↑/↓ prefix search) as framework defaults. They're now declared directly in
  `domains/00-core.zsh` — if a key or option you relied on seems to have
  changed, that file is where to look.
- **`~/.oh-my-zsh` is safe to delete** once this is merged and `~/.zshrc`
  sources `init.zsh` directly (see the companion PR in the `cg` dotfiles
  repo) — nothing here still reads from it. Leaving it in place is harmless,
  just unused disk.
