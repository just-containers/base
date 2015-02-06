# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set the PS1 prompt (with colors).

bldred='\e[1;31m' # Red
bldblu='\e[1;34m' # Blue
bldwht='\e[1;37m' # White
txtrst='\e[0m'    # Text Reset
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green

smiley() {
    ret_val=$?
    if [ "$ret_val" = "0" ]; then
        echo -e "${txtgrn}:)"
    else
        echo -e "${txtred}:( (`printf '0x%02x\n' $ret_val`)"
    fi
}

if [[ ${EUID} == 0 ]] ; then
    PS1="\[$bldwht\][ \[$bldred\]\u@\h \$(smiley) \[$txtrst\]\[$bldwht\]] \[$bldwht\]\w\[$txtrst\]\n\[$bldred\]#\[$txtrst\]> "
else
    PS1="\[$bldwht\][ \[$bldblu\]\u@\h \$(smiley) \[$txtrst\]\[$bldwht\]] \[$bldwht\]\w\[$txtrst\]\n\[$bldblu\]$\[$txtrst\]> "
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
