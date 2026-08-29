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

### Editor tooling

Language servers are the one class of tool `packages.yaml` deliberately does
not own. They are declared in `dot_config/nvim/lua/plugins/lsp.lua` and
installed by Mason, because they are useful only inside the editor and their
names differ per backend — the list would fragment across Homebrew and mise for
no gain. Mason's `PATH = "append"` means a server that *is* declared in
`packages.yaml` still wins, so promoting one later costs nothing.

A server is enabled by the existence of `dot_config/nvim/after/lsp/<name>.lua`.
Neovim finds `lsp/<name>.lua` anywhere on the runtimepath and merges them, so
those files hold only the overrides; the base config comes from
nvim-lspconfig. Nothing keeps an enable list in sync — the file is the switch.

Everything installs itself on first launch. `run_onchange_after_30` only
front-loads it so a freshly applied machine is ready before nvim is first
opened, and re-runs when the server or parser list changes. It skips quietly
when `node` or `tree-sitter` are missing rather than failing a package at a
time.

### Typeface

The font lives in one place, `.chezmoidata/fonts.yaml`: `cask` is what the
package script installs, `family` is interpolated into Ghostty and Zed. Change
those two values and `chezmoi apply` to switch typeface everywhere.

### Colour scheme

`.chezmoidata/theme.yaml` holds a `theme` selector and a `themes` table. Point
the selector at another key in the table, `chezmoi apply`, and Ghostty, bat,
herdr, Zed, Neovim, the oh-my-posh palette and the Claude Code status line all
follow.

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

### Claude Code status line

`dot_claude/executable_statusline.sh.tmpl` renders two rows under the Claude
Code prompt: the working directory and revision on top, then the session state
— model and effort, context meter, rate-limit windows, session cost.

Every value comes from the JSON payload Claude Code pipes to the script on
stdin, bar one. Nothing is read back out of `~/.claude/projects/`, and no token
is priced locally, so there is no cache to warm and no price table to go stale.
Claude Code already computes the session cost itself; reconstructing it from
transcript tokens undershot its own figure by 4–6%, because Haiku side-calls
and web-search requests never reach the transcript.

The exception is the revision, which no payload field carries, so the script
walks up from the working directory looking for one. `.jj` is checked before
`.git`, deliberately: in a colocated repo `.git/HEAD` sits on a bare commit
permanently, so reading it reports a SHA where the bookmark is the useful
thing. That is the same precedence the prompt uses via oh-my-posh's
`disable_with_jj`. The revset is `heads(::@ & bookmarks())` — `heads` rather
than `latest` so an ambiguous history reports every equidistant bookmark
instead of silently choosing one.

In a jj repo the row carries the closest bookmark, how many revisions sit above
it, and the change id of `@`. One `jj log` covers all three: it lists the
bookmark and every revision above it, and since anything strictly between the
closest bookmark and `@` carries no bookmark of its own — if it did, it would
be the closer one — an empty bookmark field marks a revision as ahead. The
change id is split into `.prefix()` and `.rest()` so the unique part can be
highlighted the way jj highlights it itself.

`--ignore-working-copy` is load-bearing: without it `jj` snapshots the working
copy on every render, which is a write, and on a large tree far slower (76ms
against 26ms on a React Native repo, which also refuses to snapshot its 100MB+
Pods artefacts). Nothing shown depends on a snapshot — the bookmark, the
revisions above it and the change id are all properties of committed revisions
— so there is no staleness to trade for that.

Fields Claude Code omits simply drop out of the row rather than rendering as a
zero — effort on a model with no effort setting, `five_hour`/`seven_day` on an
account with no windows, `spend_limit` on anything but gateway auth, worktree
fields outside a worktree. That is what lets one script serve both the personal
subscription and the work enterprise seat without branching on `profile`: the
payload decides what is relevant, not the template.

A rate-limit window also shows how long it has left, but only past 80% — below
that the percentage is the whole story and the time is noise. The countdown
floors rather than rounds, so it understates by up to a minute, which is the
right direction for time remaining.

Colours follow the same role-keyed palette as the prompt. The status line draws
on a transparent background throughout, so every role resolves to a light
accent, per the invariant above. `theme.yaml` stores hex and terminals want
24-bit ANSI, so the script converts with bash arithmetic — a builtin, costing
no forks.

It renders in ~25ms outside a repo and ~50ms in a jj one, where the single `jj
log` call is most of the difference. Reading stdin and extracting the working
directory are both done with bash builtins rather than `cat` and a second `jq`;
those two forks alone were 16ms of a 41ms render. The field match tolerates
whitespace around the JSON colon even though Claude Code emits compact JSON — a
pretty-printed payload would otherwise lose the revision name silently, which
is the sort of failure a status line never reports.

Glyphs are written as jq `\uXXXX` escapes rather than literals. The Nerd Font
icons live in the Private Use Area, which does not survive every editor and
pipeline that touches this file; the escapes keep the source pure ASCII.
Codepoints are verified present in Maple Mono NF.

`jq` is declared in `packages.yaml` for this, even though macOS 27 now ships
one at `/usr/bin/jq` — the same reasoning that applies to `ripgrep` above.

Wiring lives in `~/.claude/settings.json`, which chezmoi deliberately does not
own outright: NotchBar writes its own hooks into that file, Claude Code's
`/config` rewrites it, and a work machine carries keys this one should never
see, so a managed copy would fight all three. `dot_claude/modify_settings.json`
is a modify template instead. It parses whatever is there, sets the shared keys
— `statusLine` among them, with its path built from `.chezmoi.homeDir` — and
leaves everything else alone. Removing a line from it stops managing that key
rather than deleting it; use `unset` for that.

Touch `~/.claude/.statusline-debug` to dump each payload to
`~/.claude/.statusline-payload-<session>.json` for inspection. The filename
carries the session id because every session on the machine honours the same
marker, and a shared target gets torn between concurrent writers.

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
