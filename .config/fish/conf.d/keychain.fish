if status is-interactive
    set -g SSH_KEYS_TO_AUTOLOAD github vpshelha

    # Check if the keychain file exists and source it directly
    if test -f ~/.keychain/(hostnamectl hostname)-fish
        source ~/.keychain/(hostnamectl hostname)-fish
    end

    # Only run the full keychain command if the socket is missing (first login)
    if not set -q SSH_AUTH_SOCK
        eval (keychain --eval --quiet $SSH_KEYS_TO_AUTOLOAD)
    end
end
