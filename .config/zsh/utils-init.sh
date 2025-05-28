is_linux() {
	[[ "$(uname)" == "Linux" ]]
}

is_macos() {
	[[ "$(uname)" == "Darwin" ]]
}

bind_key() {
	local key="$1"
	local action="$2"
	[[ -n "$key" ]] && bindkey -- "$key" "$action"
}

is_command_available() {
	local cmd="$1"
	command -v "$cmd" &>/dev/null
}

source_first_found() {
	local files=("$@")
	for file in "${files[@]}"; do
		if [ -f "$file" ]; then
			source "$file" &>/dev/null
			return 0
		fi
	done
	return 1
}
