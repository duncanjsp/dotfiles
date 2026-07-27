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
