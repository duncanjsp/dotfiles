# Output helpers, included into each run_ script by chezmoi at render time.
# Do not write a template call in this file's comments: chezmoi renders this
# file too, so a literal include of itself recurses until it hits the depth cap.
#
# gum is installed *by* this repo, so on a fresh machine the earliest scripts
# run before it exists and still have to say something useful. It also expects a
# terminal, and `chezmoi apply` over SSH or from a cron job has none. Both cases
# fall back to plain printf rather than failing or emitting escape codes into a
# log. Only non-interactive gum verbs are used for the same reason.
if command -v gum >/dev/null 2>&1 && [ -t 1 ]; then
	_have_gum=1
else
	_have_gum=0
fi

# A section heading, printed once per script.
header() {
	if [ "$_have_gum" -eq 1 ]; then
		gum style --border rounded --border-foreground 4 --padding "0 1" "$*"
	else
		printf '\n== %s ==\n' "$*"
	fi
}

# Ordinary progress.
say() {
	if [ "$_have_gum" -eq 1 ]; then
		gum style --foreground 4 "  $*"
	else
		printf '  %s\n' "$*"
	fi
}

# Something was skipped or needs the user's attention; never fatal.
warn() {
	if [ "$_have_gum" -eq 1 ]; then
		gum style --foreground 3 "  ! $*" >&2
	else
		printf '  ! %s\n' "$*" >&2
	fi
}

# Fatal.
die() {
	if [ "$_have_gum" -eq 1 ]; then
		gum style --foreground 1 "  ✗ $*" >&2
	else
		printf '  x %s\n' "$*" >&2
	fi
	exit 1
}
