# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A custom oh-my-zsh plugin directory. It is activated by setting `ZSH_CUSTOM` in `~/.zshrc` to point to this repo's root.

## Architecture

There are two oh-my-zsh plugins in `plugins/`:

- **personalize** — The main plugin. Its entry point (`personalize.plugin.zsh`) defines a `personalize` function that `find`s and `source`s every `*.zsh` file under `setups/` in alphabetical order, calls it, then invokes `cleanpath` to deduplicate `$PATH`.
- **zsh-fast-syntax-highlighting** — Sources the Homebrew-installed fast-syntax-highlighting plugin.

### personalize setup structure

Each subdirectory under `plugins/personalize/setups/<context>/` contains four files:
- `aliases.zsh` — shell aliases
- `exports.zsh` — environment variable exports
- `functions.zsh` — shell functions
- `rc.zsh` — run-control (PATH additions, tool initialization)

Contexts: `zsh` (global), `osx` (macOS-specific). To add a new context (e.g. `linux/`), create a directory with the same four-file shape.

### Load order (and a gotcha)

Files are sourced in alphabetical order by full path. With the current contexts that means:

```
osx/aliases.zsh → osx/exports.zsh → osx/functions.zsh → osx/rc.zsh
→ zsh/aliases.zsh → zsh/exports.zsh → zsh/functions.zsh → zsh/rc.zsh
```

`$OS` is exported in `zsh/exports.zsh`, but it is referenced by `osx/aliases.zsh` and `zsh/aliases.zsh` which both load *earlier*. On a fresh shell `$OS` is empty when those files run, so `[[ "$OS" == 'osx' ]]` falls through to the non-macOS branch. If you are touching platform-conditional logic in an `aliases.zsh`, either move the conditional into `rc.zsh` or set `$OS` inline at the top of the file rather than relying on `zsh/exports.zsh`.

`cleanpath` (defined in `zsh/functions.zsh`) only runs after every setup file has been sourced, so individual `rc.zsh` files can prepend duplicate path entries without worrying about deduplication.

## Key Conventions

- All setup files use `*.zsh` extension and are plain zsh shell.
- Platform-conditional logic uses the `$OS` variable (set in `zsh/exports.zsh` from `uname`): values are `osx` or `linux`. This is used for cross-platform differences like `ls` color flags (`-G` on macOS, `--color=auto` on Linux).
- Optional tool aliases (httpie, docker-compose, docker-machine, SourceTree, 1Password CLI) are guarded with `command -v` or path checks so they only load when the tool is installed.
- Homebrew availability is checked with `type brew &>/dev/null` or `command -v` before using brew paths.
- Use functions instead of aliases when positional arguments (`$1`, `$@`) are needed — aliases don't support arguments.
- Use single quotes for aliases that reference shell variables (like `$PWD`) that should expand at runtime, not at definition time.
- The `cg` function provides a bare-repo git workflow for dotfiles (`~/.cg/`).

## Testing changes

There is no build or test suite. To verify changes:

- Open a new shell (or `exec zsh`) — this re-runs the full plugin chain end-to-end, which is the most realistic check.
- For a faster iteration on a single setup file, `source plugins/personalize/setups/<context>/<file>.zsh` directly, but be aware this skips the alphabetical ordering and the trailing `cleanpath` call.
- After changes, sanity-check `echo $PATH | tr : '\n'` for duplicates or surprising ordering, and confirm guarded blocks (e.g. `command -v op`) still no-op cleanly when the tool is absent.
