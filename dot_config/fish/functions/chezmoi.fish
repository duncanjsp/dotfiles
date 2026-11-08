function chezmoi --wraps chezmoi --description 'chezmoi, with diff routed through revdiff'
    if test "$argv[1]" = diff; and command -q revdiff
        command chezmoi diff $argv[2..] | revdiff --stdin
    else
        command chezmoi $argv
    end
end
