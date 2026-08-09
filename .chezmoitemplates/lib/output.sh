# Output helpers for the run_ scripts.
#
# gum is installed by these scripts, so the first run on a new machine happens
# before it exists; chezmoi apply over SSH also has no TTY for it to draw on.
# Both fall back to printf.
if command -v gum >/dev/null 2>&1 && [ -t 1 ]; then
	_have_gum=1
else
	_have_gum=0
fi

header() {
	if [ "$_have_gum" -eq 1 ]; then
		gum style --border rounded --border-foreground 4 --padding "0 1" "$*"
	else
		printf '\n== %s ==\n' "$*"
	fi
}

say() {
	if [ "$_have_gum" -eq 1 ]; then
		gum style --foreground 4 "  $*"
	else
		printf '  %s\n' "$*"
	fi
}

warn() {
	if [ "$_have_gum" -eq 1 ]; then
		gum style --foreground 3 "  ! $*" >&2
	else
		printf '  ! %s\n' "$*" >&2
	fi
}

die() {
	if [ "$_have_gum" -eq 1 ]; then
		gum style --foreground 1 "  ✗ $*" >&2
	else
		printf '  x %s\n' "$*" >&2
	fi
	exit 1
}
