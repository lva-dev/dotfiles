#!/usr/bin/env bash

DRY_RUN=

function confirm-overwrite() {
  if [[ -n $DRY_RUN ]]; then
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

DOTFILES=(
  bash_aliases
  bash_functions
  bash_logout
  bash_profile
  bashrc
  dircolors
  gdbinit
  inputrc
  profile
)

LINUX_BINARIES=(
  bin/gen-project  
)

WSL_BINARIES=(
  bin/code
  bin/explorer
)

INPUT_DIRECTORY="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
OUTPUT_DIRECTORY="$PWD"

function make-directories {
  if [[ -n $DRY_RUN ]]; then
    return 0
  fi

  if [[ "${#LINUX_BINARIES}" -gt 0 || "${#WSL_BINARIES}" -gt 0 ]]; then
    mkdir -p "$OUTPUT_DIRECTORY/bin"
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
  realpath --relative-to="$(dirname "$1")" "$INPUT_DIRECTORY"
}

function symlink-file() {
  local in_filename
  local in_relative_directory
  local in_file
  local out_file

  in_filename="$1"
  in_relative_directory="$(get-relative-to-input-dir "$in_filename")"
  in_file="$in_relative_directory/$in_filename"
  
  out_file="$OUTPUT_DIRECTORY/$1"
  [[ $2 == '-h' ]] && out_file="$(hide-file "$out_file")"

  echo -n " linking $(hide-file "$1")"
  if [[ -n $DRY_RUN ]]; then
    echo -n " ('$in_file' -> '$out_file')... "
  else
    echo -n '... '
    ln -sf "$in_file" "$out_file"
  fi
  
  echo "done"
}

function symlink-dotfiles() {
  for file in "${DOTFILES[@]}"; do
    symlink-file "$file" -h
  done
}

if [[ $(uname -r) =~ (m|M)icrosoft ]]; then
  WSL=y
fi

function symlink-binaries() {  
  for file in "${LINUX_BINARIES[@]}"; do
    symlink-file "$file"
  done

  if [[ -n $WSL ]]; then
    for file in "${WSL_BINARIES[@]}"; do
      symlink-file "$file"
    done
  fi
}

if confirm-overwrite; then
  echo "Symlinking dotfiles..."
  make-directories
  symlink-dotfiles
  symlink-binaries
  echo "Successfully linked dotfiles"
else
  exit 1
fi