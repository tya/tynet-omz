# tynet-omz

Custom plugins and shell configuration for [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh).

## Setup

Set `ZSH_CUSTOM` in your `~/.zshrc` to point to this repo:

```zsh
ZSH_CUSTOM=$HOME/path/to/tynet-omz
```

Then add the plugins to your `~/.zshrc` plugins list:

```zsh
plugins=(personalize zsh-fast-syntax-highlighting)
```

The following oh-my-zsh settings should be set in `~/.zshrc` before sourcing oh-my-zsh:

```zsh
COMPLETION_WAITING_DOTS="true"
DISABLE_AUTO_TITLE="true"
DISABLE_CORRECTION="true"
```

For Homebrew completions, add `eval "$(brew shellenv)"` to your `~/.zprofile` or `~/.zshrc` before sourcing oh-my-zsh.

## Plugins

- **personalize** — Aliases, exports, functions, and PATH setup, organized by context (`zsh` for global, `osx` for macOS-specific). Automatically sources all `*.zsh` files under `setups/` in alphabetical order. Optional tool aliases (httpie, docker, SourceTree) are only loaded when the tool is installed.
- **zsh-fast-syntax-highlighting** — Loads Homebrew's [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting).

## Cross-platform

Works on both macOS and Linux. Platform detection uses `uname` and sets `$OS` to `osx` or `linux`. The `ls` aliases automatically use the correct color flag for each platform.
