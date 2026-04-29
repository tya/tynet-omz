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

- **personalize** — Aliases, exports, functions, and PATH setup, organized by context (`zsh` for global, `osx` for macOS-specific).
- **zsh-completions** — Hooks Homebrew's [zsh-completions](https://github.com/zsh-users/zsh-completions) into `FPATH`.
- **zsh-fast-syntax-highlighting** — Loads Homebrew's [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting).
