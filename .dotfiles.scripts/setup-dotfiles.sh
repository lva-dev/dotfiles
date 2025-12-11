#!/usr/bin/env bash

echo "running this command will overwrite your existing dotfiles."
echo -n "are you sure you want to do this? (y/N): "

input=
read input

if [[ "$input" == 'n' || "$input" == 'N' ]]; then
	exit 0
elif [[ -n "$input" && "$input" != 'y' && "$input" != 'Y' ]]; then
	echo "error: invalid input. will not overwrite existing dotfiles." >&2
	exit 1
fi

files=()
readarray -d '' files < <(find ./.dotfiles/ ! -wholename '*/.git/*' ! -wholename '*/.dotfiles.scripts/*' -type f -print0)

mkdir -p bin

for file in "${files[@]}"; do
	parent="$(basename "$(dirname "$file")")"

	if [[ "$parent" == 'bin' ]]; then
		chmod +x "$file"
	fi
done

for file in "${files[@]}"; do
  parent="$(dirname "$file")"
  mkdir -p "$parent"
  real="$(realpath "$file")"
  relative="./${real#"$HOME/.dotfiles/"}"
  echo "copying to '$relative'..."
  cp -f "$file" "$relative" 
done

echo "successfully created/wrote dotfiles"
