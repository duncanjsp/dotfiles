## Dotfiles

These are my dotfiles, which are managed by [chezmoi](https://www.chezmoi.io/).

### Machine axes

Three independent facts describe a machine, computed once at `chezmoi init`.
Every conditional keys off exactly one of them:

| Axis          | Values               | Drives                                                |
| ------------- | -------------------- | ----------------------------------------------------- |
| `profile`     | `personal` / `work`  | git identity, signing key, work remotes, encrypted blob |
| `.chezmoi.os` | `darwin` / `linux`   | package manager, platform binary paths                 |
| `gui`         | `true` / `false`     | Ghostty, herdr, Zed, commit signing                    |

Which gives:

| Machine       | profile    | os       | gui   | Tooling  | Signing |
| ------------- | ---------- | -------- | ----- | -------- | ------- |
| `fantasmic`   | `personal` | `darwin` | yes   | Homebrew | yes     |
| `test-track`  | `work`     | `darwin` | yes   | Homebrew | yes     |
| Linux desktop | `personal` | `linux`  | yes   | mise     | yes     |
| Linux server  | `personal` | `linux`  | no    | mise     | no      |

A server is not a profile: it is Linux with `gui = false`. Keeping the axes
separate is what lets a personal Linux desktop exist without every conditional
growing a new case.

Signing follows the GUI axis rather than the OS, because it is done by the
1Password desktop app — a headless box has no `op-ssh-sign` to call. Only the
binary's path varies by platform.

Work is exactly one Mac, so only that machine ever decrypts anything; nothing
else needs the 1Password CLI or the age key.

### Packages

`.chezmoidata/packages.yaml` holds two lists, one per backend. macOS uses
Homebrew; Linux uses mise, which is user-local, needs no sudo and behaves
identically on Debian-based and immutable distros — so desktops and servers
share it rather than splitting on the distro's package manager. The mise list
is split into `core` and `gui`, the latter being desktop-only.

Tools are declared even when something else would drag them in: `tree-sitter`
arrives as a Homebrew dependency of neovim and `node@20` as a dependency of
other formulae, but both are used directly. Leaning on a transitive dependency
is exactly how `ripgrep` — which Telescope's live grep needs — stayed
undeclared until a server, with no Mac drift to hide behind, exposed it.

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

### Bootstrapping a Linux box

The repo is public and pulls anonymously over HTTPS, so no credentials, SSH key
or 1Password access are required.

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply duncanjsp
```

Unknown hosts are asked once whether they are a desktop. The default is `no`,
so a non-interactive server bootstrap lands on the safe answer.

`run_before_05-linux-prereqs.sh` handles what needs root. It installs `make`
and a C compiler — nvim-treesitter builds parsers with `cc` and
`telescope-fzf-native` compiles C — plus zsh, then makes zsh the login shell.
`build-essential` and `@development-tools` are deliberately avoided: both drag
in `g++` and packaging tooling that nothing here uses.

This is the only script that has to know about more than one package manager,
because everything else comes from mise. It tries, in order:

| Condition                    | Action                                            |
| ---------------------------- | ------------------------------------------------- |
| `apt-get` + passwordless sudo | installs `make gcc libc6-dev zsh`                 |
| Homebrew present             | installs `make gcc zsh` — the immutable-distro path |
| `rpm-ostree` present         | prints both options, changes nothing               |
| `dnf` present                | prints the command                                 |
| none of the above            | prints what is missing                            |

On atomic distros such as Bazzite, `rpm-ostree install` builds a new deployment
that only takes effect after a reboot, so it is never run automatically — no
`chezmoi apply` should reboot a machine on your behalf. Homebrew is Bazzite's
own recommendation for CLI tooling and needs neither root nor a reboot, which
is why it is preferred there.

Everything runs under `sudo -n` and never prompts: with passwordless sudo it
just works, otherwise it prints the commands and carries on. `git` and `curl`
are assumed present — the bootstrap line above cannot run without them.

If the login shell could not be changed — `chsh` also refuses shells missing
from `/etc/shells`, which is where a Homebrew zsh trips — `.bash_profile` execs
into zsh for interactive logins instead, so either route lands you in the right
shell.

Subsequent updates are `chezmoi update`.

### Script output

The `run_` scripts share `.chezmoitemplates/lib/output.sh`, which uses
[gum](https://github.com/charmbracelet/gum) when it is available and falls back
to plain `printf` when it is not. Both fallbacks matter: gum is installed *by*
these scripts, so the first run on a new machine happens before it exists, and
`chezmoi apply` over SSH has no TTY for it to draw on.
