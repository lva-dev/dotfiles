#!/usr/bin/env bash

DRY_RUN=y

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

LINUX_USER_BINARIES=(
  local/bin/gen-project  
)

WSL_SYSTEM_BINARIES=(
  usr/local/bin/code
  usr/local/bin/explorer
)

INPUT_DIRECTORY="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
OUTPUT_DIRECTORY="$PWD"

function make-directories {
  if [[ -n $DRY_RUN ]]; then
    return 0
  fi

  if [[ "${#LINUX_USER_BINARIES}" -gt 0 || "${#WSL_SYSTEM_BINARIES}" -gt 0 ]]; then
    mkdir -p "$OUTPUT_DIRECTORY/.local"
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
    in_file="$(realpath -m "$INPUT_DIRECTORY/$1")"
    out_file="$2"
  else
    in_filename="$(basename "$1")"
    in_relative_directory="$(get-relative-to-input-dir "$1")"
    in_file="$in_relative_directory/$in_filename"
    out_file="$OUTPUT_DIRECTORY/$2"
  fi

  echo -n " linking "
  is-hidden "$2" && echo -n ".$1"
  is-abs "$2" && echo -n "/$1"
  
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
    symlink-file "$file" ".$file"
  done
}

if [[ $(uname -r) =~ (m|M)icrosoft ]]; then
  WSL=y
fi

function symlink-binaries() {  
  for file in "${LINUX_USER_BINARIES[@]}"; do
    symlink-file "$file" ".$file"
  done

  if [[ -n $WSL ]]; then
    for file in "${WSL_SYSTEM_BINARIES[@]}"; do
      symlink-file "$file" "/$file"
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