status is-interactive; or return

set -g fish_greeting

fish_vi_key_bindings
set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_replace_one underscore
set -g fish_cursor_visual block

set -gx EZA_COLORS "uu=36:uR=31:un=35:gu=37:da=2;34:ur=34:uw=95:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36:xx=95:"

abbr -a ls eza -a --icons
abbr -a ll eza -al --no-user --time-style long-iso --icons --git
abbr -a lt eza -aTL 3 --icons
abbr -a cat bat

command -q starship; and starship init fish | source
command -q atuin; and atuin init fish | source
