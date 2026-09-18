#
# ~/.bash_aliases
#

#
# Builtins
#
alias ls='ls -hF --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias '..'='cd ..'
alias tempd='cd "$(mktemp -d)"'
alias grep='grep --color=auto'
alias less='less -r'
alias df='df -h'
alias du='du -h'

#
# Programs
#
command -v bat >/dev/null     && alias bat='bat -p'
command -v clang++ >/dev/null && alias clang++='clang++ -std=c++23'
command -v code >/dev/null    && alias c='code'
command -v emacs >/dev/null   && alias emacs='emacs -nw'
command -v gdb >/dev/null     && alias gdb='gdb -q'
command -v wikiman >/dev/null && alias wman='wikiman'