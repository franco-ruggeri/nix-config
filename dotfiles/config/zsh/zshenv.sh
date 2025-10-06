zsh_config_path="$HOME/.config/zsh"
source $zsh_config_path/utils-init.sh

if is_darwin; then
  # Homebrew
	eval "$(/opt/homebrew/bin/brew shellenv)"

  # AIChat
	export AICHAT_CONFIG_DIR="$HOME/.config/aichat"
fi

source $zsh_config_path/utils-clear.sh
