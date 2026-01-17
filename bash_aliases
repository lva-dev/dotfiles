#
# ~/.bash_aliases
#

#
# Aliases for builtin commands
#

alias '..'='cd ..'

alias ls='ls -hF --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lld='ls -alFd'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

alias grep='grep --color=auto'

alias less='less -r'

alias df='df -h'
alias du='du -h'

alias tempd='cd "$(mktemp -d)"'
alias restart='tput clear; exec bash -l'

#
# Other commands
#

command -v xdg-open >/dev/null && alias open='xdg-open'
command -v trash >/dev/null && alias rm='echo "\"rm\" has been disabled. Use \"trash\" instead." >&2'
command -v clang >/dev/null && alias cc='clang'
command -v xclip >/dev/null && alias clip='xclip -selection clipboard'
command -v fzf >/dev/null && alias fzf-history='history | cut -c 8- | fzf'
command -v google-chrome >/dev/null && alias google-chrome='google-chrome --profile-directory=Default'
command -v gdb >/dev/null && alias gdb='gdb -q'
command -v emacs >/dev/null && alias emacs='emacs -nw'
