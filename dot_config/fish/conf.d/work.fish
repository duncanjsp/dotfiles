set -gx DIRENV_WARN_TIMEOUT 0
set -gx CLOUDSMITH_API_KEY "op://Employee/Cloudsmith API Key/credential"
set -gx GOPATH $HOME/go
set -gx GOPRIVATE "go.1password.io,gitlab.1password.io,proto.1infra.dev,github.com/agilebits-inc"
set -gx ANDROID_HOME $HOME/Library/Android/sdk
fish_add_path --global --append --path $GOPATH/bin

status is-interactive; or return

abbr -a yarn op run --account agilebits --no-masking -- yarn
abbr -a cdb5 cd $GOPATH/src/go.1password.io/b5

command -q direnv; and direnv hook fish | source
