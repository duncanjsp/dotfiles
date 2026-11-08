eval "$(direnv hook zsh)"

# Nix-backed direnv is always slow.
export DIRENV_WARN_TIMEOUT=0

export CLOUDSMITH_API_KEY="op://Employee/Cloudsmith API Key/credential"
alias yarn="op run --account agilebits --no-masking -- yarn"

export GOPATH=$HOME/go
export GOPRIVATE="go.1password.io,gitlab.1password.io,proto.1infra.dev,github.com/agilebits-inc"
export PATH=$PATH:$GOPATH/bin

export ANDROID_HOME=$HOME/Library/Android/sdk

alias cdb5="cd $GOPATH/src/go.1password.io/b5"
alias assume=". assume"
