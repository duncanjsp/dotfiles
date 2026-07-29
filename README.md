## Dotfiles

These are my dotfiles, which are managed by [chezmoi](https://www.chezmoi.io/).

### Profiles

A `profile` is computed once, at `chezmoi init`, and drives every conditional:

| Profile    | Detected by           | Tooling  | Signing |
| ---------- | --------------------- | -------- | ------- |
| `personal` | hostname `fantasmic`  | Homebrew | yes     |
| `work`     | hostname `test-track` | Homebrew | yes     |
| `server`   | any Linux host        | mise     | no      |

Servers additionally skip all GUI configuration (Ghostty, herdr, Zed) and never
decrypt anything, so they need neither the 1Password CLI nor the age key.

### Typeface

The font lives in one place, `.chezmoidata/fonts.yaml`: `cask` is what the
package script installs, `family` is interpolated into Ghostty and Zed. Change
those two values and `chezmoi apply` to switch typeface everywhere.

### Colour scheme

`.chezmoidata/theme.yaml` holds a `theme` selector and a `themes` table. Point
the selector at another key in the table, `chezmoi apply`, and Ghostty, bat,
herdr, Zed, Neovim and the oh-my-posh palette all follow.

Each theme entry carries whatever each tool needs, because none of them agree
on naming: Ghostty and Zed want `Catppuccin Mocha`, herdr wants `catppuccin`,
Neovim wants a plugin path and a flavour, and oh-my-posh wants raw hex.

The oh-my-posh palette is keyed by role — `accent`, `path`, `ok`, `warn`,
`error` — rather than by hue, so a theme can put any colour behind any role.
One rule holds across every theme: a coloured background always pairs with
`fg_on_accent`, and a transparent background always takes a light accent as
its foreground. Ignoring it is how you end up with pale grey on pale peach.

eza, fastfetch and atuin are absent from the table on purpose — they render in
terminal ANSI, so they follow Ghostty's palette for free.

Themes that aren't built into a tool are vendored next to its config:
`dot_config/ghostty/themes/dracula-pro` and `dot_config/zed/themes/`. Zed
installs its theme extension itself via `auto_install_extensions`.

### Bootstrapping a server

The repo is public and servers pull anonymously over HTTPS, so no credentials,
SSH key or 1Password access are required.

Install the prerequisites first. These are not managed by chezmoi because they
need `sudo`, and mise cannot sensibly provide a login shell or a C toolchain:

```sh
sudo apt update && sudo apt install -y zsh git curl build-essential
```

`build-essential` supplies `make` and a C compiler, which
`telescope-fzf-native.nvim` needs at build time.

Then:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply duncanjsp
chsh -s "$(which zsh)"
```

Log out and back in. Subsequent updates are `chezmoi update`.
