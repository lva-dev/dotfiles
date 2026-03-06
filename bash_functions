#
# ~/.bash_functions
#

# Usage: path
# Prints the paths in PATH, split by newlines.
path() {
  echo "$PATH" | tr ':' '\n'
}

# Usage: newf <path>
# Creates a new file.
newf() {
	for path in "$@"; do
		if [[ -f "$path" ]]; then
			echo -e "error: file '$path' already exists"
			return 1
		elif [[ -d "$path" ]]; then
			echo -e "error: '$path' is a directory"
			return 1
		elif [[ -e "$path" ]]; then
			echo -e "error: path '$path' already exists"
			return 1
		fi

		mkdir -p "$(dirname "$path")" && touch "$path"
	done
}

# Usage: colors
# Prints some basic terminal colors.
colors() (
	function pcolor() {
		local n="$1"
		local fg=$((0 + n))
		local bg=$((10 + n))
		echo -ne "\e[${fg}m${fg}\e[m "
		echo -ne "\e[${bg}m${bg}\e[m\n"
	}

	for n in {30..37}; do
		pcolor "$n"
	done

	for n in {90..97}; do
		pcolor "$n"
	done
)

if command -v fzf >/dev/null && command -v fzf >/dev/null; then
  fzf-history() {
    local output="$(history | cut -c 8- | fzf "$@")"
    echo "$output"
    xclip -selection clipboard <<< "$output"
  }
fi

if command -v trash >/dev/null; then 
  rm() {
    echo "'rm' is disabled. Use 'trash' instead." >&2
  }
fi