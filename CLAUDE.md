# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A custom oh-my-zsh plugin directory. It is activated by setting `ZSH_CUSTOM` in `~/.zshrc` to point to this repo's root.

## Architecture

There are three oh-my-zsh plugins in `plugins/`:

- **personalize** — The main plugin. Its entry point (`personalize.plugin.zsh`) sources all `*.zsh` files found under `setups/` (sorted alphabetically), then calls `cleanpath` to deduplicate `$PATH`.
- **zsh-completions** — Wires up Homebrew's zsh-completions into `FPATH`.
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

- All setup files use `*.zsh` extension and are plain POSIX-ish shell with zsh extensions.
- Platform-conditional logic uses the `$OS` variable (set in `zsh/exports.zsh` from `uname`): values are `osx` or `linux`.
- Homebrew availability is checked with `type brew &>/dev/null` or `command -v` before using brew paths.
- The `cg` alias provides a bare-repo git workflow for dotfiles (`~/.cg/`).
