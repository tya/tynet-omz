# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A custom oh-my-zsh plugin directory. It is activated by setting `ZSH_CUSTOM` in `~/.zshrc` to point to this repo's root.

## Architecture

There are two oh-my-zsh plugins in `plugins/`:

- **personalize** — The main plugin. Its entry point (`personalize.plugin.zsh`) sources all `*.zsh` files found under `setups/` (sorted alphabetically via process substitution), then calls `cleanpath` to deduplicate `$PATH`.
- **zsh-fast-syntax-highlighting** — Sources the Homebrew-installed fast-syntax-highlighting plugin.

### personalize setup structure

Each subdirectory under `plugins/personalize/setups/<context>/` contains four files:
- `aliases.zsh` — shell aliases
- `exports.zsh` — environment variable exports
- `functions.zsh` — shell functions
- `rc.zsh` — run-control (PATH additions, tool initialization)

Contexts: `zsh` (global), `osx` (macOS-specific).

Files are sourced in alphabetical order by full path, so `osx/` loads before `zsh/`. The `cleanpath` function (defined in `zsh/functions.zsh`) is called after all setups are sourced.

## Key Conventions

- All setup files use `*.zsh` extension and are plain zsh shell.
- Platform-conditional logic uses the `$OS` variable (set in `zsh/exports.zsh` from `uname`): values are `osx` or `linux`. This is used for cross-platform differences like `ls` color flags (`-G` on macOS, `--color=auto` on Linux).
- Optional tool aliases (httpie, docker-compose, docker-machine, SourceTree, 1Password CLI) are guarded with `command -v` or path checks so they only load when the tool is installed.
- Homebrew availability is checked with `type brew &>/dev/null` or `command -v` before using brew paths.
- Use functions instead of aliases when positional arguments (`$1`, `$@`) are needed — aliases don't support arguments.
- Use single quotes for aliases that reference shell variables (like `$PWD`) that should expand at runtime, not at definition time.
- The `cg` function provides a bare-repo git workflow for dotfiles (`~/.cg/`).
