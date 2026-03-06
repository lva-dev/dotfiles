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