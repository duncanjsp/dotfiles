set -gx GOPATH $XDG_DATA_HOME/go
set -gx GOBIN $XDG_DATA_HOME/go/bin

test -r ~/.orbstack/shell/init2.fish; and source ~/.orbstack/shell/init2.fish
