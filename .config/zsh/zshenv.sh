source $ZDOTDIR/utils-init.sh

# Homebrew
if is_macos; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Dark theme
# See https://wiki.archlinux.org/title/Dark_mode_switching
# TODO: I'm trying to use rose-pine. If it works, remove this. Apparently, there's no stable theme for Qt apps.
if is_linux; then
	export GTK_THEME="Adwaita:dark"
	export GTK2_RC_FILES="/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc"
	export QT_STYLE_OVERRIDE="Adwaita-Dark"
fi

# Gnome keyring for ssh-agent
# See https://wiki.archlinux.org/title/GNOME/Keyring#Setup_gcr
if is_linux; then
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

# Tmux plugin manager
if is_linux; then
	export TPM_PATH="$HOME/.config/tmux/plugins/tpm/tpm"
elif is_macos; then
	export TPM_PATH="$HOMEBREW_PREFIX/opt/tpm/share/tpm/tpm"
fi

# Zathura
if is_macos; then
	export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET"
fi

source $ZDOTDIR/utils-clear.sh
