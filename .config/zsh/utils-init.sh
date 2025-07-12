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

load_secret() {
	local secret_name="$1"

	local secret_file
	secret_file=$(echo "$secret_name" | tr '[:upper:]' '[:lower:]') # lowercase
	secret_file="${secret_file//_/-}"                               # underscore -> dash
	secret_file="$HOME/.secrets/${secret_file}.gpg"                 # path to secret file

	if [ -f "$secret_file" ]; then
		export $secret_name=$(gpg --decrypt --quiet "$secret_file")
	else
		echo "Warning: Secret file $secret_file not found. Skipping $secret_name."
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
