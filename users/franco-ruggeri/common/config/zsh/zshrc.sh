zsh_config_path=$HOME/.config/zsh
source $zsh_config_path/utils-init.sh
source $zsh_config_path/aliases.sh
source $zsh_config_path/keybindings.sh

# Kubernetes
if is_command_available kubectl; then
	source <(kubectl completion zsh)
fi

# Devpod
if is_command_available devpod; then
	source <(devpod completion zsh)
fi

# AIChat
if is_command_available aichat; then
	source <(curl -sSL https://raw.githubusercontent.com/sigoden/aichat/main/scripts/shell-integration/integration.zsh)
	source <(curl -sSL https://raw.githubusercontent.com/sigoden/aichat/main/scripts/completions/aichat.zsh)
fi

# Ericsson
if is_darwin; then
	source $HOME/.ericsson
fi

source $zsh_config_path/utils-clear.sh
