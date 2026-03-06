#!/usr/bin/env bash

DRY_RUN=n
VERBOSE=n

if [[ $(uname -r) =~ (m|M)icrosoft ]]; then
  WSL=y
fi

INPUT_DIRECTORY="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
OUTPUT_DIRECTORY="$PWD"

prompt() {
  local in
  read -r in
  if [[ $in == [nN] ]]; then
    return 1
  elif [[ -z $in || $in == [yY] ]]; then
    return 0
  else
    return 2
  fi
}

make-directories() {
  if [[ -n $DRY_RUN ]]; then
    return 0
  fi

  if [[ "${#LINUX_USER_BINARIES}" -gt 0 ]]; then
    mkdir -p "$OUTPUT_DIRECTORY/.local/bin"
  fi
}
  
hiddenname() {
  if (($# == 0)); then
    echo "error: missing argument" >&2
    echo "Usage: hiddenname [PATH]..."
    return 1
  fi
  
  for arg in "$@"; do
    local path
    if [[ $arg == '.' ]]; then
      path="$(realpath "$arg")"
    elif [[ $arg == '/' ]]; then
      echo "/"
      break
    else
      path="$arg"
    fi
    
    local base
    base="$(basename "$path")"

    if [[ $base == .* ]]; then
      echo "$path"
      break
    fi
    
    local dir
    if [[ $path != */* ]]; then
      dir=
    else
      dir="$(dirname "$path")/"
    fi
    
    echo "$dir.$base" 
  done
  
  return 0
}

get-relative-to-input-dir() {
  if [[ "${1:0:1}" == '/' ]]; then
    dirname "$1"
  else
    realpath -m --relative-to="$(dirname "$1")" "$INPUT_DIRECTORY"
  fi
}

is-absolute() {
  [[ "${1:0:1}" == '/' ]]
}

is-hidden() {
  local without_root_slash="${1#/}"
  [[ "${without_root_slash:0:1}" == '.' ]]
}

link-file() {
  local in_filename
  local in_relative_directory
  local in_file
  local out_file
  
  if is-absolute "$2"; then
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
  is-absolute "$2" && echo -n "$2"
  
  if [[ $VERBOSE == 'y' ]]; then
    echo -n " ('$in_file' -> '$out_file')"
  fi

  echo -n '... '

  if [[ $DRY_RUN == 'y' ]]; then
    if [[ ! -w $(dirname "$out_file") ]]; then
      echo "failed to link file"
      return 1
    fi
  else
    if ! ln -sf "$in_file" "$out_file" &>/dev/null; then
      echo "failed to link file"
      return 1
    fi
  fi

  echo "done"
  return 0
}

parse-args() {
  local opts
  if ! opts=$(getopt -n "$(basename "$0")" -o 'vh' -l 'dry-run,verbose,help' -- "$@"); then
    exit 1
  fi

  # shellcheck disable=SC2086
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

command-exists() {
  command -v "$1" >/dev/null
}

main() {
  parse-args "$@"
  
  local run
  if [[ $DRY_RUN == 'y' ]]; then
    run=y
    make-directories
  else
    echo "Running this command will overwrite your existing dotfiles."
    echo -n "Are you sure you want to do this? [Y/n]: "  
    prompt

    local errc=$?
    if ((errc == 0)); then
      run=y
    elif ((errc == 1)); then
      run=n
    else
      echo -e "\e[31merror:\e[m invalid input" >&2
      return 1;
    fi
  fi
  
  if [[ $run == 'y' ]]; then
    echo "Symlinking dotfiles..."

    link-file 'bash_aliases' '.bash_aliases'
    link-file 'bash_functions' '.bash_functions'
    link-file 'bash_logout' '.bash_logout'
    link-file 'bash_profile' '.bash_profile'
    link-file 'bashrc' '.bashrc'
    link-file 'dircolors' '.dircolors'
    link-file 'gdbinit' '.gdbinit'
    link-file 'inputrc' '.inputrc'

    link-file 'localbin/gen-project' '.local/bin/gen-project'

    if command-exists clang; then
      link-file "$INPUT_DIRECTORY/sysbin/cc" "$LOCAL_CC"
    fi

    if command-exists clang++; then
      link-file "$INPUT_DIRECTORY/sysbin/c++" "$LOCAL_CXX"
    fi

    if command-exists xdg-open; then
      link-file "$INPUT_DIRECTORY/sysbin/open" "$LOCAL_OPEN"
    fi

    if [[ -n $WSL ]]; then
      link-file "$INPUT_DIRECTORY/sysbin/code" '/usr/local/bin/code'
      link-file "$INPUT_DIRECTORY/sysbin/explorer" '/usr/local/bin/explorer'
    fi
    
    echo "Successfully linked dotfiles"
  else
    exit 1
  fi
}

main "$@"
