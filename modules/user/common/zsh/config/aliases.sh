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
