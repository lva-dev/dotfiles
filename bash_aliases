#
# ~/.bash_aliases
#

#
# Aliases for builtin commands
#

alias '..'='cd ..'

# ls
alias ls='ls -hF --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lld='ls -alFd'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

alias grep='grep --color=auto'

alias less='less -r'   # raw control characters

alias df='df -h'
alias du='du -h'

alias tempd='cd "$(mktemp -d)"'
alias restart='tput clear; exec bash -l'

#
# Other commands
#

alias open='xdg-open'
command -v trash >/dev/null && alias rm='echo "\"rm\" has been disabled. Use \"trash\" instead." >&2'
command -v clang >/dev/null && alias cc='clang'
command -v xclip >/dev/null && alias clip='xclip -selection clipboard'
alias gdb='gdb -q'
alias emacs='emacs -nw'
alias google-chrome='google-chrome --profile-directory=Default'