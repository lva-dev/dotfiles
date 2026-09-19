#
# ~/.bash_functions
#

# Usage: new <PATH>...
# Creates a new file for each <PATH> if it doesn't exist.
# If the parent directory of the file doesn't exist, then it will be created with the file.
function new() (
  function echo-error() {
    echo -n $'\e[31merror:\e[m ' >&2
    echo "$@" >&2
  }
  
  if (($# == 0)); then
    echo-error $'missing argument \e[36m<FILE>\e[m'
  fi
  
	for path in "$@"; do
		if [[ -f "$path" ]]; then
			echo-error "file '$path' already exists"
			return 1
		elif [[ -d "$path" ]]; then
			echo-error "'$path' is a directory"
			return 1
		elif [[ -e "$path" ]]; then
			echo-error "path '$path' already exists"
			return 1
		fi

		mkdir -p "$(dirname "$path")" && touch "$path"
	done
)

alias n=new

# Usage: list-colors
# Prints some basic terminal colors.
function list-colors() {
  local range=({30..37} {90..97})
	for n in "${range[@]}"; do
		local foreground=$((0 + n))
    printf "\e[${foreground}m%-3s\e[m" "$foreground"
	done
  echo
  for n in "${range[@]}"; do
		local background=$((10 + n))
    printf "\e[${background}m%-3s\e[m" "$background"
	done
  echo
}

# Usage: list-path
# Prints the paths in PATH, split by newlines.
function list-path() {
  echo "$PATH" | tr ':' '\n'
}

if command -v fzf >/dev/null; then
  . 'scripts/fzf-history.sh'

  alias hzh=fzf-history
fi

if command -v trash >/dev/null; then 
  function rm() {
    echo $'\e[31merror:\e[39m `rm` is disabled' >&2
    echo $'\e[33mnote:\e[39m use `trash` instead' >&2
  }
fi

if command -v xclip >/dev/null; then
  function clip() {
    xclip -r -selection clipboard "$@"
  }
fi

if command -v python >/dev/null; then
  function json() {
    python -m json "$@"
  }
fi

if [[ "$(grep -i '^ID=' /etc/os-release)" == "ubuntu" ]]; then
  function apt-find() {
    apt search --names-only "${@:2}" "^$1\$"
  }
fi