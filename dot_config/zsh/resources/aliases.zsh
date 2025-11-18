# Aliases for eza
# eza https://eza.rocks/
alias ls="eza -a --icons"
alias ll="eza -al --no-user --time-style long-iso --icons --git"
alias lt="eza -aTL 3 --icons"

# bar is a better cat with syntax highlighting
alias cat="bat"

# Handy git aliases
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'
alias gunwip='git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'
