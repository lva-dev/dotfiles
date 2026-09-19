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
function fzf-history() (
  function echo-error() { echo -n $'\e[31merror:\e[m ' >&2; echo "$@" >&2; }
  function echo-note() { echo -n $'\e[33mnote:\e[m '; echo "$@"; }
  function unexpected-arg() { echo-error -e "unexpected argument '\e[33m$1\e[m'"; }

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