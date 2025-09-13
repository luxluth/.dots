#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    export MOZ_ENABLE_WAYLAND=1
    export MOZ_DBUS_REMOTE=1
fi

. "$HOME/.cargo/env"

export PATH="$PATH:/home/luxluth/.dotnet/tools"
