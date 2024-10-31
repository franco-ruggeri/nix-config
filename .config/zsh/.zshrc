source $ZDOTDIR/.utils
source $ZDOTDIR/.aliases
source $ZDOTDIR/.keybindings

# Prompt theme (with Oh My Posh)
# See https://ohmyposh.dev/docs/installation/customize
eval "$(oh-my-posh init zsh --config ~/.local/share/oh-my-posh/theme.omp.json)"

# Command completion
# See https://wiki.archlinux.org/title/Zsh#Command_completion
autoload compinit
compinit
zstyle ':completion:*' menu select

# Fish-like syntax highlighting
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

# Tmux plugin manager
if is_linux; then
    export TPM_PATH="$HOME/.tmux/plugins/tpm/tpm"
elif is_macos; then
    export TPM_PATH="$HOMEBREW_PREFIX/opt/tpm/share/tpm/tpm"
fi

# Kubernetes
if command -v kubectl 2>&1 >/dev/null; then
    source <(kubectl completion zsh)
fi

# ER Cloud
if is_macos; then
    source $HOME/.ercloud
fi
