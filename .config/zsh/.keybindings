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

# Key bindings for history search of matching commands
# See https://wiki.archlinux.org/title/Zsh#History_search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bind_key "$terminfo[kcuu1]" up-line-or-beginning-search
bind_key "$terminfo[kcud1]" down-line-or-beginning-search
