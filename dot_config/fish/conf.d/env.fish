set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_STATE_HOME $HOME/.local/state

switch (uname)
    case Darwin
        set -l tmp /tmp
        set -q TMPDIR; and set tmp $TMPDIR
        set -gx XDG_RUNTIME_DIR (string trim -r -c / -- $tmp)/xdg-runtime-(id -u)
        /opt/homebrew/bin/brew shellenv fish | source
        fish_add_path --global --move --path $HOME/.local/bin /opt/homebrew/opt/node@20/bin
    case '*'
        set -gx XDG_RUNTIME_DIR /run/user/(id -u)
        if contains -- "$LANG" "" C POSIX
            set -gx LANG C.UTF-8
        end
        if not set -q SSH_CONNECTION; and test -S $HOME/.1password/agent.sock
            set -gx SSH_AUTH_SOCK $HOME/.1password/agent.sock
        end
        test -x /home/linuxbrew/.linuxbrew/bin/brew; and /home/linuxbrew/.linuxbrew/bin/brew shellenv fish | source
        fish_add_path --global --move --path $HOME/.local/bin
end

if not test -d $XDG_RUNTIME_DIR
    mkdir -p $XDG_RUNTIME_DIR
    chmod 700 $XDG_RUNTIME_DIR
end

set -gx BUNDLE_USER_CONFIG $XDG_CONFIG_HOME/bundle
set -gx BUNDLE_USER_CACHE $XDG_CACHE_HOME/bundle
set -gx BUNDLE_USER_PLUGIN $XDG_DATA_HOME/bundle
set -gx NPM_CONFIG_USERCONFIG $XDG_CONFIG_HOME/npm/config
set -gx NPM_CONFIG_CACHE $XDG_CACHE_HOME/npm
set -gx LESSHISTFILE $XDG_DATA_HOME/less/lesshst

set -gx EDITOR nvim
set -gx SHELL (command -s fish)

command -q mise; and mise activate fish | source
