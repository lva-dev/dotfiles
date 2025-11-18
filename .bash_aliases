#
# ~/.bash_aliases
#

# Aliases for builtin commands

alias '..'='cd ..'
alias '...'='cd ../..'
for ((n = 1; n <= 10; n++)); do
    alias_name=".$(for ((i = 0; i < n; i++)); do echo -n '.'; done)"
    alias_value="cd $(for ((i = 0; i < n; i++)); do echo -n '../'; done)"
    eval "alias '$alias_name'='$alias_value'"; 
done

alias ls='ls -hF --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lld='ls -alFd'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias less='less -r'   # raw control characters
alias whence='type -a' # where, of a sort
alias df='df -h'
alias du='du -h'
alias tempd='cd "$(mktemp -d)"'
alias restart='tput clear; exec bash -l'
alias rm='echo "\"rm\" has been disabled. Use \"trash\" instead." >&2'
alias open='xdg-open'


# Other commands
command -v clang >/dev/null && alias cc='clang'
command -v xclip >/dev/null && alias clip='xclip -selection clipboard'
alias gdb='gdb -q'
alias google-chrome='google-chrome --profile-directory=Default'