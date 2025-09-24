zsh_config_path="$HOME/.config/zsh"
source $zsh_config_path/utils-init.sh

# Homebrew
if is_darwin; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# AIChat
if is_darwin; then
	export AICHAT_CONFIG_DIR="$HOME/.config/aichat"
fi

source $zsh_config_path/utils-clear.sh
