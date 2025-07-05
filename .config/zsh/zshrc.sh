source $ZDOTDIR/utils-init.sh
source $ZDOTDIR/aliases.sh
source $ZDOTDIR/keybindings.sh

# Prompt theme (with Oh My Posh)
# See https://ohmyposh.dev/docs/installation/customize
eval "$(oh-my-posh init zsh --config $HOME/.local/share/oh-my-posh/theme.omp.json)"

# Command completion
# See https://wiki.archlinux.org/title/Zsh#Command_completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select

# Fish-like syntax highlighting and autosuggestions
# See https://wiki.archlinux.org/title/Zsh#Fish-like_syntax_highlighting_and_autosuggestions
if is_linux; then
	# Source from several locations to support different distro
	filepaths=(
		"/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
		"/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	)
	source_first_found "${filepaths[@]}"
	if [ $? -ne 0 ]; then
		echo "Warning: zsh-syntax-highlighting not found."
	fi

	filepaths=(
		"/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
		"/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
	)
	source_first_found "${filepaths[@]}"
	if [ $? -ne 0 ]; then
		echo "Warning: zsh-autosuggestions not found."
	fi
elif is_macos; then
	source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Command-not-found handler
# See https://wiki.archlinux.org/title/Zsh#pkgfile_%22command_not_found%22_handler
if is_linux; then
	source /usr/share/doc/pkgfile/command-not-found.zsh >/dev/null 2>&1
fi

# Don't add to history commands starting with space, like in Bash
# See https://unix.stackexchange.com/questions/6094/is-there-any-way-to-keep-a-command-from-being-added-to-your-history
setopt HIST_IGNORE_SPACE

# Kubernetes
if is_command_available kubectl; then
	source <(kubectl completion zsh)
fi

# Fzf
if is_command_available fzf; then
	source <(fzf --zsh)
fi

# Devpod
if is_command_available devpod; then
	source <(devpod completion zsh)
fi

# Ericsson
if is_macos; then
	source $HOME/.ericsson
fi

source $ZDOTDIR/utils-clear.sh
