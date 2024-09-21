# Default editor
# It also defines the key bindings for zsh and tmux.
# See https://wiki.archlinux.org/title/Zsh#Key_bindings
# See https://github.com/tmux/tmux/wiki/Getting-Started#vi1-key-bindings
export VISUAL=vim
export EDITOR=vim

# Dark theme
# See https://wiki.archlinux.org/title/Dark_mode_switching
export GTK_THEME=Adwaita:dark
export GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc
export QT_STYLE_OVERRIDE=Adwaita-Dark

# Gnome keyring for ssh-agent
# See https://wiki.archlinux.org/title/GNOME/Keyring#Setup_gcr
export SSH_AUTH_SOCK="/run/user/1000/gcr/ssh"

# Pipx
path=("/Users/erugfra/.local/bin" $path)
