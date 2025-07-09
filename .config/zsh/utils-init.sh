is_linux() {
	[ "$(uname)" = "Linux" ]
}

is_macos() {
	[ "$(uname)" = "Darwin" ]
}

bind_key() {
	local key="$1"
	local action="$2"
	[ -n "$key" ] && bindkey -- "$key" "$action"
}

is_command_available() {
	local cmd="$1"
	command -v "$cmd" >/dev/null 2>&1
}

source_first_found() {
	local files=("$@")
	for file in "${files[@]}"; do
		if [ -f "$file" ]; then
			source "$file" >/dev/null 2>&1
			return 0
		fi
	done
	return 1
}

load_api_key() {
	local key_name="$1"
	local key_file="$2"
	if [ -f "$key_file" ]; then
		export $key_name=$(gpg --decrypt --quiet ~/.secrets/gemini-api-key.gpg)
	fi
}

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
