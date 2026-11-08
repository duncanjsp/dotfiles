function assume --description 'Granted: assume an AWS role in this shell'
    source (command -s assume.fish) $argv
end
