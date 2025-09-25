zsh_config_dir="$HOME/.config/zsh"
source $zsh_config_dir/utils-init.sh

# Aliases
# ====================
alias ls="ls --color=auto"
alias ll="ls -lh"
alias la="ls -lAh"
alias vi="nvim"
alias vim="nvim"
if is_linux; then
	alias open="xdg-open"
fi

aichat() {
	if [ -z $GEMINI_API_KEY ]; then
		load_secret GEMINI_API_KEY
	fi
	command aichat "$@"
}
# ====================

# Key bindings
# ====================
bindkey -v

# Terminal application mode (to make $terminfo valid)
# See https://wiki.archlinux.org/title/Zsh#Key_bindings
if [[ -n "$terminfo[smkx]" && -n "$terminfo[rmkx]" ]]; then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start {
		echoti smkx
	}
	function zle_application_mode_stop {
		echoti rmkx
	}
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# Basic key bindings
bind_key "$terminfo[khome]" beginning-of-line
bind_key "$terminfo[kend]" end-of-line
bind_key "$terminfo[kdch1]" delete-char
bind_key "$terminfo[kcbt]" reverse-menu-complete

# History search of matching commands
# See https://wiki.archlinux.org/title/Zsh#History_search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bind_key "$terminfo[kcuu1]" up-line-or-beginning-search
bind_key "$terminfo[kcud1]" down-line-or-beginning-search
# ====================

# Menu selection for completions
# See https://wiki.archlinux.org/title/Zsh#Command_completion
zstyle ':completion:*' menu select

if is_command_available kubectl; then
	source <(kubectl completion zsh)
fi

if is_command_available devpod; then
	source <(devpod completion zsh)
fi

if is_command_available aichat; then
	source <(curl -sSL https://raw.githubusercontent.com/sigoden/aichat/main/scripts/shell-integration/integration.zsh)
	source <(curl -sSL https://raw.githubusercontent.com/sigoden/aichat/main/scripts/completions/aichat.zsh)
fi

if is_darwin; then
	source $HOME/.ericsson
fi

source $zsh_config_dir/utils-clear.sh
