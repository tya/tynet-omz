# oh-my-zsh-custom

Custom plugins and shell configuration for [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh).

## Setup

Set `ZSH_CUSTOM` in your `~/.zshrc` to point to this repo:

```zsh
ZSH_CUSTOM=$HOME/path/to/oh-my-zsh-custom
```

Then add the plugins to your `~/.zshrc` plugins list:

```zsh
plugins=(personalize zsh-completions zsh-fast-syntax-highlighting)
```

## Plugins

- **personalize** — Aliases, exports, functions, and PATH setup, organized by context (`zsh` for global, `osx` for macOS-specific). Automatically sources all `*.zsh` files under `setups/` in alphabetical order. Optional tool aliases (httpie, docker, SourceTree) are only loaded when the tool is installed.
- **zsh-completions** — Hooks Homebrew's [zsh-completions](https://github.com/zsh-users/zsh-completions) into `FPATH`.
- **zsh-fast-syntax-highlighting** — Loads Homebrew's [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting).

## Cross-platform

Works on both macOS and Linux. Platform detection uses `uname` and sets `$OS` to `osx` or `linux`. The `ls` aliases automatically use the correct color flag for each platform.
