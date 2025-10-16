zsh_config_path="$HOME/.config/zsh"
source "$zsh_config_path/utils-init.sh"

if is_darwin; then
	# Homebrew
	eval "$(/opt/homebrew/bin/brew shellenv)"

	# AIChat
	export AICHAT_CONFIG_DIR="$HOME/.config/aichat"
fi

# In devcontainers, the Nix feature does not source the Nix profile in Zsh.
# Thus, we add the binaries to the path explicitly.
path+=("$HOME/.nix-profile/bin")

# Set XDG_SESSION_TYPE in Hyprland.
# Needed for obsidian.nvim img_paste to work properly.
if is_linux && [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
	export XDG_SESSION_TYPE="wayland"
fi

source "$zsh_config_path/utils-clear.sh"
