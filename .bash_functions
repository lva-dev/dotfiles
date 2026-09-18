#
# ~/.bash_functions
#

# Usage: newf <PATH>...
# Creates a new file for each <PATH> if it doesn't exist.
# If the parent directory of the file doesn't exist, then it will be created with the file.
new() (
  echo-error() {
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
list-colors() (
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
)

# Usage: list-path
# Prints the paths in PATH, split by newlines.
list-path() {
  echo "$PATH" | tr ':' '\n'
}

if command -v fzf >/dev/null; then
  # Usage:
  #   fzf-history [-e|--echo]
  #   fzf-history -x|--execute
  #   fzf-history -c|--copy
  # 
  # Uses fzf (fuzzy finder) to search the shell's history list and prints, executes, or copies (to
  # the clipboard) the matched history entry.
  #
  # If -x is set, exits with the status of the matched command.
  #
  # Exit Status:
  #   0    No errors
  #   1    No match
  #   2    Interrupted with CTRL-C or ESC
  #   3    fzf error
  fzf-history() (
    echo-error() { echo -n $'\e[31merror:\e[m ' >&2; echo "$@" >&2; }
    echo-note() { echo -n $'\e[33mnote:\e[m '; echo "$@"; }
    unexpected-arg() { echo-error -e "unexpected argument '\e[33m$1\e[m'"; }

    if (($# > 1)); then
      unexpected-arg "$2"
      return 1
    fi
    
    command -v xclip >/dev/null
    local found_xclip=$(($? == 0))
    
    local action
    local arg="$1"
    if (($# == 0)) || [[ $arg == '-e' || $arg == '--echo' ]]; then
      action='echo'
    elif [[ $arg == '-x' || $arg == '--execute' ]]; then
      action='execute'
    elif [[ $1 == '-c' || $1 == '--copy' ]]; then
      if ((found_xclip)); then
        action='copy'
      else
        unexpected-arg "$1"
        echo-note '`xclip` is not installed on this system'
        return 2
      fi
    else
      unexpected-arg "$1"
      return 2
    fi

    local cmd
    cmd="$(history | cut -c 8- | fzf --scheme=history --tac)"
    local err=$?
    if ((err == 1)); then
      echo "${FUNCNAME[0]}: no match" >&2
      return 1;
    elif ((err == 130)); then
      echo "${FUNCNAME[0]}: interrupted" >&2
      return 2
    elif ((err != 0)); then
      echo -n "${FUNCNAME[0]}: " >&2
      echo-error 'fzf failed'
      return 3
    fi
    
    if [[ $action == 'echo' ]]; then
      echo "$cmd"
      return 0
    elif [[ $action == 'execute' ]]; then
      eval "$cmd"
      return
    elif ((found_xclip)) && [[ $action == 'copy' ]]; then
      if xclip -r -selection clipboard <<< "$cmd"; then
        return 0
      else
        return 1
      fi
    fi
  )

  alias hzh=fzf-history
fi

if command -v trash >/dev/null; then 
  rm() {
    echo $'\e[31merror:\e[39m `rm` is disabled' >&2
    echo $'\e[33mnote:\e[39m use `trash` instead' >&2
  }
fi

if command -v xclip >/dev/null; then
  clip() {
    xclip -r -selection clipboard "$@"
  }
fi

if command -v python >/dev/null; then
  json() {
    python -m json "$@"
  }
fi
