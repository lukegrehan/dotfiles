[ -z "$PS1" ] && return

PATH=$PATH:~/.local/bin

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
HISTIGNORE="history:l:shutdown*:incog:pass*"

PROMPT_DIRTRIM=3

shopt -s histappend
shopt -s checkwinsize
shopt -s globstar
shopt -s cdspell
shopt -s extglob
shopt -s checkjobs

[ -x /usr/bin/lesspipe ] &&
	eval "$(SHELL=/bin/sh lesspipe)"
[ -f /usr/share/git/completion/git-prompt.sh ] &&
	. /usr/share/git/completion/git-prompt.sh
[ -x /usr/local/bin/colours.sh ] &&
	. /usr/local/bin/colours.sh

export EDITOR=vim

PS1='[$(t=$?;if [[ $t == 0 ]]; then echo "\[$Green\]"; else echo "\[$Red\]($t) "; fi)\w\[$Yellow\]$(__git_ps1)\[$NC\]] \$ '

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alFh --group-directories-first'
alias la='ls -v -A --group-directories-first'
alias l='ls -v -CF --group-directories-first'
alias alert='notify-send --urgency=critical  -t 10000 "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -n "$VIRTUAL_ENV" ]; then
    . "$VIRTUAL_ENV/bin/activate"
fi


# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION
