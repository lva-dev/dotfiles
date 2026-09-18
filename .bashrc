#
# ~/.bashrc
#

# If not running interactively, exit
[[ "$-" != *i* ]] && return

# PATH

if [[ ! "$PATH" =~ (^|:)"${HOME}/.local/bin"(:|$) ]]; then
	PATH="$PATH:${HOME}/.local/bin"
fi

#
# Bash
#

[[ -f "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"
[[ -f "$HOME/.bash_functions" ]] && source "$HOME/.bash_functions"

# Shell options
set -o ignoreeof    # Disable ^D for logout
shopt -s nocaseglob # Enable case-insensitive filename globbing
stty susp ''        # Disable suspend (job control) key
unset HISTFILE

# History
export HISTCONTROL="${HISTCONTROL}${HISTCONTROL+:}ignoredups:erasedups"

# Completion
[[ -f "/usr/share/bash-completion/bash_completion" ]] && source "/usr/share/bash-completion/bash_completion"
complete -r ls

# Prompts

# I lowkey don't remember what this does. Well comment it out until we figure it out.
# PROMPT_COMMAND='printf "\033]0;%s\007" "arch: ${PWD/#$HOME/\~}"'
# if wslinfo --networking-mode &>/dev/null; then
# 	PROMPT_COMMAND='printf "\e]9;9;%s\e\\" "$(wslpath -w "$PWD")"'
# fi

[[ -f "$HOME/.local/scripts/git-prompt.sh" ]] && source "$HOME/.local/scripts/git-prompt.sh"

PS1="$(
	COLOR_END='\[\e[m\]'
	COLOR_SSH='\[\e[38;5;104m\]'
	COLOR_USER=''
	COLOR_HOST='\[\e[38;5;7m\]'
	COLOR_DIR='\[\e[38;5;3m\]'

	echo -n "[$COLOR_USER\u$COLOR_END"

	if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
		echo -n "@$COLOR_HOST\H$COLOR_END (${COLOR_SSH}ssh$COLOR_END)"
	fi

	echo -n " $COLOR_DIR\W$COLOR_END"

	if [[ "$(type -t __git_ps1)" == 'function' ]]; then
		echo -n '$(__git_ps1 " (%s)")'
	fi

	echo -n ']$ '
)"

#
# Misc
#

# man/bat
if command -v bat >/dev/null && command -v batman >/dev/null; then
	eval "$(batman --export-env)"
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# fzf
command -v fzf >/dev/null && eval "$(fzf --bash)"

# zoxide
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd bash)"

# VS Code
if wslinfo --networking-mode &>/dev/null && command -v code >/dev/null; then
	export EDITOR=code
elif command -v micro >/dev/null; then
	export EDITOR=micro
fi

# Browser
if wslinfo --networking-mode &>/dev/null; then
	[[ -z $BROWSER ]] && { export BROWSER=wsl-open || export BROWSER=$BROWSER:wsl-open; }
fi

# SSH (ssh-agent)
if command -v ssh-agent >/dev/null && [[ -z "$SSH_AUTH_SOCK" ]]; then
	eval "$(ssh-agent -s)" >/dev/null
fi

# 
# Programming Language-Speciic
# 
# CMake
export CMAKE_EXPORT_COMPILE_COMMANDS=ON
export CMAKE_COLOR_DIAGNOSTICS=ON
export CMAKE_LINKER_TYPE=LLD
export CMAKE_C_COMPILER_ID=Clang
export CMAKE_CXX_COMPILER_ID=Clang

# rust/cargo
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# dotnet
if [[ -d "$HOME/.dotnet" ]]; then
	export DOTNET_ROOT=$HOME/.dotnet

	if [[ ! "$PATH" =~ (^|:)"$DOTNET_ROOT"(:|$) ]]; then
		export PATH="$PATH:$DOTNET_ROOT"
	fi

	if [[ ! "$PATH" =~ (^|:)"$DOTNET_ROOT/tools"(:|$) ]]; then
		export PATH="$PATH:$DOTNET_ROOT/tools"
	fi
fi