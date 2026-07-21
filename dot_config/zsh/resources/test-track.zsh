# Enable DirEnv, used by the Core toolchain
eval "$(direnv hook zsh)"

# Stop Direnv moaning about taking ages even though it ALWAYS takes ages when Nix is involved
export DIRENV_WARN_TIMEOUT=0

# Auth for Packages
export GITHUB_TOKEN="op://Employee/GitHub Token EMU/password"
export CLOUDSMITH_API_KEY="op://Employee/Cloudsmith API Key/credential"
alias yarn="op run --account agilebits --no-masking -- yarn"

# Go Config for server
export GOPATH=$HOME/go
export GOPRIVATE="go.1password.io,gitlab.1password.io,proto.1infra.dev,github.com/agilebits-inc"
export PATH=$PATH:$GOPATH/bin

# Android crap
export ANDROID_HOME=$HOME/Library/Android/sdk

# Aliases
alias cdb5="cd $GOPATH/src/go.1password.io/b5"
