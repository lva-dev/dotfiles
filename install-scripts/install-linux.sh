#!/usr/bin/env bash

DRY_RUN=n
VERBOSE=n

if [[ $(uname -r) =~ (m|M)icrosoft ]]; then
  WSL=y
fi

INPUT_DIRECTORY="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
OUTPUT_DIRECTORY="$PWD"

function confirm-overwrite() {
  if [[ $DRY_RUN == 'y' ]]; then
    return 0
  fi
  
  local input
  echo "Running this command will overwrite your existing dotfiles."
  echo -n "Are you sure you want to do this? (y/N): "
  read -r input

  if [[ "$input" == 'n' || "$input" == 'N' ]]; then
    return 0
  elif [[ -n "$input" && "$input" != 'y' && "$input" != 'Y' ]]; then
    echo -e "\e[31merror:\e[m Invalid input. Exiting script." >&2
    return 1
  fi
}

function make-directories {
  if [[ -n $DRY_RUN ]]; then
    return 0
  fi

  if [[ "${#LINUX_USER_BINARIES}" -gt 0 ]]; then
    mkdir -p "$OUTPUT_DIRECTORY/.local/bin"
  fi
}

function hide-file() {
  local base
  local parent
  local joined
  base="$(dirname "$1")"
  base="${base/./''}"
  base="$base${base:+/}"
  parent="$(basename "$1")"
  joined="$base.$parent"
  echo "$joined"
}

function get-relative-to-input-dir() {
  if [[ "${1:0:1}" == '/' ]]; then
    dirname "$1"
  else
    realpath -m --relative-to="$(dirname "$1")" "$INPUT_DIRECTORY"
  fi
}

function is-subfile() {
  local dir
  local file
  local relative
  dir="$(realpath -m "$1")"
  file="$(realpath -m "$2")"
  relative="${file#"$dir"}"
  if [[ "$relative" == "$file" ]]; then
    return 1
  else
    return 0
  fi
}

function is-abs() {
  [[ "${1:0:1}" == '/' ]]
}

function is-hidden() {
  local without_root_slash="${1#/}"
  [[ "${without_root_slash:0:1}" == '.' ]]
}

function symlink-file() {
  local in_filename
  local in_relative_directory
  local in_file
  local out_file
  
  if is-abs "$2"; then
    in_file="$(realpath -m "$1")"
    out_file="$2"
  else
    in_filename="$(basename "$1")"
    in_relative_directory="$(get-relative-to-input-dir "$1")"
    in_file="$in_relative_directory/$in_filename"
    out_file="$OUTPUT_DIRECTORY/$2"
  fi

  echo -n " linking "
  is-hidden "$2" && echo -n ".$1"
  is-abs "$2" && echo -n "$2"
  
  if [[ $VERBOSE == 'y' ]]; then
    echo -n " ('$in_file' -> '$out_file')... "
  else
    echo -n '... '
  fi

  local ln_errc=0
  if [[ $DRY_RUN == 'n' ]]; then
    ln -sf "$in_file" "$out_file" &>/dev/null 
    ln_errc=$?
  fi

  if [[ $ln_errc == 0 ]]; then
    echo "done"
    return 0
  else
    echo "failed to link file"
    return 1
  fi
}

function clparse() {
  local opts
  if ! opts=$(getopt -n "$(basename "$0")" -o 'vh' -l 'dry-run,verbose,help' -- "$@"); then
    exit 1
  fi

  set -- $opts

  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        echo "Usage: $(basename "$0") [-h|--help] [-v|--verbose] [--dry-run]"
        echo
        echo "Options:"
        echo "      --dry-run   Don't link any files"
        echo "  -v, --verbose   Use verbose output"
        echo "  -h, --help      Print help" 
        exit 0
        ;;
      -v|--verbose)
        VERBOSE=y
        ;;
      --dry-run)
        DRY_RUN=y
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "error: unknown option '$1'" >&2
        exit 1
        ;;
      *)
        break
        ;;
    esac
    shift
  done
}

function main() {
  clparse "$@"
  
  if confirm-overwrite; then
    echo "Symlinking dotfiles..."
    make-directories

    # ~/dotfiles
    symlink-file 'bash_aliases' '.bash_aliases'
    symlink-file 'bash_functions' '.bash_functions'
    symlink-file 'bash_logout' '.bash_logout'
    symlink-file 'bash_profile' '.bash_profile'
    symlink-file 'bashrc' '.bashrc'
    symlink-file 'dircolors' '.dircolors'
    symlink-file 'gdbinit' '.gdbinit'
    symlink-file 'inputrc' '.inputrc'
    symlink-file 'profile' '.profile'

    # ~/.local/bin/
    symlink-file 'localbin/gen-project' '.local/bin/gen-project'

    # /usr/local/bin/
    if [[ -n $WSL ]]; then
      symlink-file "$INPUT_DIRECTORY/sysbin/code" '/usr/local/bin/code'
      symlink-file "$INPUT_DIRECTORY/sysbin/explorer" '/usr/local/bin/explorer'
    fi
    
    echo "Successfully linked dotfiles"
  else
    exit 1
  fi
}

main "$@"