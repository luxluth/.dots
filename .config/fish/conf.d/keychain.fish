if status is-interactive
    set -Ua SSH_KEYS_TO_AUTOLOAD github vpshelha
    # To remove a key, set -U --erase SSH_KEYS_TO_AUTOLOAD[index]
    eval (keychain --eval --quiet $SSH_KEYS_TO_AUTOLOAD)
end
