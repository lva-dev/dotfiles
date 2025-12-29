#
# ~/.bashrc
#

# if not running interactively, exit
[[ "$-" != *i* ]] && return

# PATH
export PATH="${HOME}/.local/bin:${HOME}/bin:$PATH"

#
# bash
#

# other files
[[ -f "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"
[[ -f "$HOME/.bash_functions" ]] && source "$HOME/.bash_functions"
[[ -f "$HOME/.dircolors" ]] && source "$HOME/.dircolors"

# bash completion
[[ -f "/usr/share/bash-completion/bash_completion" ]] && source "/usr/share/bash-completion/bash_completion"

# shell options
set -o ignoreeof    # disable ^D for logout
shopt -s nocaseglob # enable case-insensitive filename globbing

# prompts
PROMPT_COMMAND='printf "\033]0;%s\007" "arch: ${PWD/#$HOME/\~}"'
PS1='['
if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
	PS1+='\[\e[38;5;32m\]ssh\[\e[m\] '
fi
PS1+='\[\e[38;5;7m\]\u\[\e[m\]'
PS1+='@\[\e[38;5;98m\]\H\[\e[m\]'
PS1+=' \[\e[38;5;3m\]\W\[\e[m\]'
PS1+=']$ '

# history
export HISTCONTROL="${HISTCONTROL}${HISTCONTROL+:}ignoredups:erasedups"
unset HISTFILE

#
# other
# stuff
#

# ssh (ssh-agent)
if command -v ssh-agent >/dev/null && [[ -z "$SSH_AUTH_SOCK" ]]; then
  eval "$(ssh-agent -s)" >/dev/null
fi

# using wsl-open as browser
if [[ $(uname -r) =~ (m|M)icrosoft ]]; then
	[[ -z $BROWSER ]] && { export BROWSER=wsl-open || export BROWSER=$BROWSER:wsl-open; }
fi

# rust / cargo
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# dotnet
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
