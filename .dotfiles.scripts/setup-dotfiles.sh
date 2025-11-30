#!/usr/bin/env bash

echo "running this command will overwrite your existing dotfiles."
echo -n "are you sure you want to do this? (y/N): "

declare input
read input

if [[ "$input" == 'n' || "$input" == 'N' ]]; then
  exit 0
elif [[ -n "$input" && "$input" != 'y' && "$input" != 'Y' ]]; then
  echo "error: invalid input. will not overwrite existing dotfiles." >&2
  exit 1
fi

declare -a files
readarray -d '' files < <(find ./.dotfiles/ ! -wholename '*/.git/*' ! -wholename '*/.dotfiles.scripts/*' -type f -print0)

declare parent
for file in "${files[@]}"; do
    parent="$(basename "$(dirname "$file")")"
    
    if [[ "$parent" == 'bin' ]]; then
	chmod +x "$file"
    fi
done

for file in "${files[@]}"; do
    cp -f "$file" . 
done

echo "successfully created/wrote dotfiles"
