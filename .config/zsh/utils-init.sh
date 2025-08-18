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

str_to_kebab_case() {
	local filename="$1"

	# Convert entire filename to kebab-case:
	# 1. Replace spaces, underscores, commas, semicolons, and colons with dashes
	# 2. Insert dashes before capital letters (except at start)
	# 3. Convert to lowercase
	# 4. Remove multiple consecutive dashes
	# 5. Remove leading/trailing dashes
	echo "$filename" |
		sed 's/[ _,;:]/-/g' |
		sed 's/\([a-z0-9]\)\([A-Z]\)/\1-\2/g' |
		tr '[:upper:]' '[:lower:]' |
		sed 's/--*/-/g' |
		sed 's/^-\|-$//g'
}

cwd_to_kebab() {
	echo "Converting cwd content to kebab-case..."
	echo "=================================="

	if [ -z "$(ls -A 2>/dev/null)" ]; then
		echo "Directory is empty - nothing to rename"
		return 0
	fi

	local count=0
	for item in *; do
		local new_name=$(str_to_kebab_case "$item")

		if [[ "$item" == "$new_name" ]]; then
			echo "✓ $item (already kebab-case)"
			continue
		fi

		if [[ -e "$new_name" ]]; then
			echo "✗ $item -> $new_name (target exists)"
			continue
		fi

		if mv "$item" "$new_name" 2>/dev/null; then
			echo "✓ $item -> $new_name"
			((count++))
		else
			echo "✗ $item -> $new_name (failed)"
		fi
	done

	echo "=================================="
	echo "Renamed $count items"
}
