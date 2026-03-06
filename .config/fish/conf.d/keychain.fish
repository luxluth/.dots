if status is-login
    and status is-interactive
    set -Ua SSH_KEYS_TO_AUTOLOAD $HOME/.ssh/github
    # To remove a key, set -U --erase SSH_KEYS_TO_AUTOLOAD[index]
    keychain --eval $SSH_KEYS_TO_AUTOLOAD | source
end
