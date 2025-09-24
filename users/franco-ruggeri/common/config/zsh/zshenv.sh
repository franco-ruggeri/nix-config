zsh_config_path=$HOME/.config/zsh
source $zsh_config_path/utils-init.sh

# Homebrew
if is_darwin; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Gnome keyring for ssh-agent.
# See https://wiki.archlinux.org/title/GNOME/Keyring#Setup_gcr
#
# Set SSH_AUTH_SOCK only if it is not already set, to avoid overriding it in remote sessions.
# See https://wiki.archlinux.org/title/SSH_keys#Forwarding_ssh-agent
if is_linux && [ -z "$SSH_AUTH_SOCK" ]; then
	export SSH_AUTH_SOCK="/run/user/1000/gcr/ssh"
fi

# Path as array of unique values
typeset -U path PATH

# Include local binaries (e.g., for pipx)
path+=($HOME/.local/bin)

# Fzf
if is_command_available fzf; then
	# Consistent layout for fzf, <C-t>, <C-r>, and <M-c>
	export FZF_DEFAULT_OPTS="--tmux=center --layout=reverse"
fi

# AIChat
if [ is_darwin ]; then
	export AICHAT_CONFIG_DIR="$HOME/.config/aichat"
fi

source $zsh_config_path/utils-clear.sh
