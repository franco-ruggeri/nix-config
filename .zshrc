# Prompt theme
# See https://wiki.archlinux.org/title/Zsh#Prompt_themes
autoload promptinit
promptinit
prompt off

# Command completion
# See https://wiki.archlinux.org/title/Zsh#Command_completion
autoload compinit
compinit
zstyle ':completion:*' menu select

# Prompt theme
autoload promptinit
promptinit
prompt off

# Fish-like syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Fish-like autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Command not found handler
# See https://wiki.archlinux.org/title/Zsh#pkgfile_%22command_not_found%22_handler
source /usr/share/doc/pkgfile/command-not-found.zsh

# ZLE vi mode
# See https://wiki.archlinux.org/title/Zsh#Key_bindings
bindkey -v

# Terminal application mode (to make $terminfo valid)
# See https://wiki.archlinux.org/title/Zsh#Key_bindings
if [[ -n "$terminfo[smkx]" && -n "$terminfo[rmkx]" ]]; then
    autoload add-zle-hook-widget
    function zle_application_mode_start {
        echoti smkx
    }
    function zle_application_mode_stop {
        echoti rmkx
    }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# Bind key function
function bind_key() {
    local key="$1"    # Get the key from the first argument
    local action="$2" # Get the action from the second argument
    [[ -n "$key" ]] && bindkey -- "$key" "$action"
}

# Basic key bindings
bind_key "$terminfo[khome]" beginning-of-line
bind_key "$terminfo[kend]" end-of-line
bind_key "$terminfo[kdch1]" delete-char
bind_key "$terminfo[kcbt]" reverse-menu-complete

# Key bindings for history search of matching commands
# See https://wiki.archlinux.org/title/Zsh#History_search
autoload up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bind_key "$terminfo[kcuu1]" up-line-or-beginning-search
bind_key "$terminfo[kcud1]" down-line-or-beginning-search

# Aliases
alias ls="ls --color=auto"
alias ll="ls -lh"
alias la="ls -lAh "
