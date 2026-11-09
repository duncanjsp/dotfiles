## Dotfiles

Managed by [chezmoi](https://www.chezmoi.io/).

### New machine

See chezmoi's [quick start](https://www.chezmoi.io/quick-start/#set-up-a-new-machine-with-a-single-command).

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply duncanjsp/dotfiles
```

Unknown hosts are asked for `gui` and `email`. The work Mac needs the 1Password CLI signed in to decrypt its config.

Make fish the login shell (macOS):

```sh
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

### Updating

```sh
chezmoi update
```

### Installed

macOS, via Homebrew:

- atuin, bat, carapace, chezmoi, direnv, eza, fastfetch, fd, fish, gh, git, go, gum, jj, jq, mise, neovim, prettier, revdiff, ripgrep, rust, starship, stylua, tree-sitter
- 1password-cli
- Maple Mono NF

Linux, via mise:

- atuin, bat, carapace, chezmoi, direnv, eza, fastfetch, fd, gh, go, gum, jj, jq, neovim, prettier, revdiff, ripgrep, starship, stylua, tree-sitter
- GUI machines also: rust, Maple Mono NF
- Via the system package manager, if missing: make, gcc, zsh

Neovim:

- Plugins via lazy.nvim
- LSP servers via Mason: bashls, gopls, jsonls, lua_ls, vtsls, yamlls, shellcheck, shfmt
- Treesitter parsers listed in `dot_config/nvim/lua/config/parsers.lua`

Package lists live in `.chezmoidata/packages.yaml`.
