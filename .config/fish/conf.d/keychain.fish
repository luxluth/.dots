if status is-interactive
    set -g SSH_KEYS_TO_AUTOLOAD sourcehunt github gitlab-gnome gitlab-freedesktop vpshelha

    # Only run the full keychain command if the socket is missing (first login)
    if not ssh-add -l >/dev/null 2>&1
        eval (keychain --eval --quiet $SSH_KEYS_TO_AUTOLOAD)
    end
end
