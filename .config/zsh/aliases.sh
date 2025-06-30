alias ls="ls --color=auto"
alias ll="ls -lh"
alias la="ls -lAh"
alias vi="nvim"
alias vim="nvim"
if is_linux; then
	alias open="xdg-open"
fi

# Some devcontainer features do not support Apple Silicon (e.g., ripgrep).
# Thus, use linux/amd64 as devcontainer platform.
if is_macos; then
	alias devpod="DOCKER_DEFAULT_PLATFORM=linux/amd64 devpod"
fi

# Workaround for poetry shell not working with custom prompt
# See https://github.com/python-poetry/poetry-plugin-shell/issues/9
poetry() {
	if [ "$1" = "shell" ]; then
		cmd='source "$(dirname $(poetry run which python))/activate"'
		zsh -ic "$cmd; exec zsh"
	else
		command poetry "$@"
	fi
}
