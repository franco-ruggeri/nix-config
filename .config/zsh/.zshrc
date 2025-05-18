source $ZDOTDIR/.utils
source $ZDOTDIR/.aliases
source $ZDOTDIR/.keybindings

# Prompt theme (with Oh My Posh)
# See https://ohmyposh.dev/docs/installation/customize
if is_command_available oh-my-posh; then
  eval "$(oh-my-posh init zsh --config $HOME/.local/share/oh-my-posh/theme.omp.json)"
fi

# Command completion
# See https://wiki.archlinux.org/title/Zsh#Command_completion
autoload compinit
compinit
zstyle ':completion:*' menu select

# Fish-like syntax highlighting and autosuggestions
# See https://wiki.archlinux.org/title/Zsh#Fish-like_syntax_highlighting_and_autosuggestions
if is_macos; then
	source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif is_linux; then
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Command-not-found handler
# See https://wiki.archlinux.org/title/Zsh#pkgfile_%22command_not_found%22_handler
if is_linux; then
	source /usr/share/doc/pkgfile/command-not-found.zsh
fi

# Don't add to history commands starting with space, like in Bash
# See https://unix.stackexchange.com/questions/6094/is-there-any-way-to-keep-a-command-from-being-added-to-your-history
setopt HIST_IGNORE_SPACE

# Kubernetes
if is_command_available kubectl; then
	source <(kubectl completion zsh)
fi

# fzf
if is_command_available fzf; then
	source <(fzf --zsh)
	export FZF_DEFAULT_OPTS="--style full --preview 'fzf-preview.sh {}'"
fi

# Devpod
if is_command_available devpod; then
  source <(devpod completion zsh)
fi

# Ericsson
if is_macos; then
	source $HOME/.ericsson
fi
