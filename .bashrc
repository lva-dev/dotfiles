#
# ~/.bashrc
#

# if not running interactively, exit
[[ "$-" != *i* ]] && return

# PATH
export PATH="$PATH:~/bin"

#
# Bash config
#

# other files
[[ -f "${HOME}/.bash_aliases" ]] && source "${HOME}/.bash_aliases"
[[ -f "${HOME}/.bash_functions" ]] && source "${HOME}/.bash_functions"
[[ -f "${HOME}/.dircolors" ]] && source "${HOME}/.dircolors"

# bash completion
[[ -f "/usr/share/bash-completion/bash_completion" ]] && source "/usr/share/bash-completion/bash_completion"

# shell options
set -o ignoreeof    # disable ^D for logout
shopt -s nocaseglob # enable case-insensitive filename globbing

# prompts
# PS1='$({ [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY"  ]; } && echo -n "\[\e[38;5;32m\]ssh\[\e[m\] ")\[\e[38;5;3m\]\W\[\e[0m\] $ '
PS1=
PS1+="$({ [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; } && printf "\[\e[38;5;32m\]ssh\[\e[m\] ")"
PS1+='[\[\e[38;5;7m\]\u\[\e[0m\]@\[\e[38;5;98m\]\H\[\e[0m\] \[\e[38;5;3m\]\W\[\e[0m\]]$ '
PROMPT_COMMAND='printf "\033]0;%s\007" "arch: ${PWD/#${HOME}/\~}"'

# history
export HISTCONTROL="${HISTCONTROL}${HISTCONTROL+:}ignoredups:erasedups"
unset HISTFILE

#
# Other
#

# ssh (ssh-agent)
[ -z "$SSH_AUTH_SOCK" ] && eval "$(ssh-agent -s)" >/dev/null

# rust/cargo
[[ -f "${HOME}/.cargo/env" ]] && source "${HOME}/.cargo/env"

# using wsl-open as browser
if [[ $(uname -r) =~ (m|M)icrosoft ]]; then
	[[ -z $BROWSER ]] && export BROWSER=wsl-open || export BROWSER=$BROWSER:wsl-open
fi

# dotnet
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
