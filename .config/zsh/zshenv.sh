source $ZDOTDIR/utils-init.sh

# Homebrew
if is_macos; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Dark theme
# See https://wiki.archlinux.org/title/Dark_mode_switching
if is_linux; then
	export GTK_THEME="Adwaita:dark"
	export GTK2_RC_FILES="/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc"
	export QT_STYLE_OVERRIDE="Adwaita-Dark"
fi

# Gnome keyring for ssh-agent
# See https://wiki.archlinux.org/title/GNOME/Keyring#Setup_gcr
if is_linux && [ -z "$SSH_AUTH_SOCK" ]; then
	export SSH_AUTH_SOCK="/run/user/1000/gcr/ssh"
fi

# Default editor
# It also defines the key bindings for zsh and tmux.
# See https://wiki.archlinux.org/title/Zsh#Key_bindings
# See https://github.com/tmux/tmux/wiki/Getting-Started#vi1-key-bindings
export VISUAL=vi
export EDITOR=vi

# Path as array of unique values
typeset -U path PATH

# Pipx and poetry
path+=($HOME/.local/bin)

# Zathura
if is_macos; then
	export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET"
fi

source $ZDOTDIR/utils-clear.sh
