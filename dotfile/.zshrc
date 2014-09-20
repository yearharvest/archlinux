#------------------------------------------------------------#
# File: .zshrc    ZSH resource file                          #
#------------------------------------------------------------#

#------------------------------
# Hook Functions
#------------------------------
precmd () {
    cwd="%3~"
    cwd="${${${(%)cwd}#\/}//\//  }"
    PS1="%F{15}%K{5} %n %F{5}%K{6}%F{15}%K{6} "%(1~,"%(4~,"…  $cwd","$cwd")","/")" %k%F{6}%f "
}

#------------------------------
# Parameters
#------------------------------
HISTFILE=~/.zhistory
HISTSIZE=10000
PATH=$PATH:$HOME/bin
RPS1=%(0?,"","%F{1}%F{15}%K{1} %? %f%k")
SAVEHIST=10000
WORDCHARS="~!@#$%^&*()-_=+[]{}\|;:,.<>/?"

export BROWSER="firefox"
export EDITOR="emacs"

#------------------------------
# Option
#------------------------------
#-----Changing Directories
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
#-----Completion
setopt ALWAYS_LAST_PROMPT
setopt AUTO_LIST
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt LIST_PACKED
setopt LIST_ROWS_FIRST
setopt LIST_TYPES
setopt MENU_COMPLETE
#-----History
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_BY_COPY
setopt INC_APPEND_HISTORY
#-----Input/Output
setopt ALIASES
setopt NO_CLOBBER
setopt FLOW_CONTROL
setopt INTERACTIVE_COMMENTS
#-----Prompting
setopt PROMPT_SUBST
setopt TRANSIENT_RPROMPT

#------------------------------
# Shell Builtin Commands
#------------------------------
#-----alias
alias grep="grep --color=auto"
alias ls="ls -F --color=auto"
alias ll="ls -lh --color=auto"
alias nano="nano -w"
alias -s gz="tar -xzvf"
alias -s bz2="tar -xjvf"

#-----bindkey
bindkey -e
bindkey "^[[2~"   overwrite-mode         #insert
bindkey "^[[3~"   delete-char            #delete
bindkey "^[[H"    beginning-of-line      #home
bindkey "^[[F"    end-of-line            #end
bindkey "^[[Z"    reverse-menu-complete  #Shift+Tab
bindkey "^[[A"    up-line-or-search      #Up
bindkey "^[[B"    down-line-or-search    #Down
bindkey "^[[C"    forward-char           #Right
bindkey "^[[1;2C" forward-word           #Shift+Right
bindkey "^[[D"    backward-char          #Left
bindkey "^[[1;2D" backward-word          #Shift+Left

#-----hash
hash -d PKG="/var/cache/pacman/pkg"
hash -d WIN="/mnt/win"
#-----limit
limit coredumpsize 0

#------------------------------
# Completion System
#------------------------------
autoload -U compinit promptinit
compinit
promptinit

zmodload -i zsh/complist
eval $(dircolors -b)
export ZLS_COLORS="${LS_COLORS}"

zstyle ':completion:*' completer _complete _correct _approximate
zstyle ':completion:*' force-list always
zstyle ':completion:*:corrections'  format $'\e[1;33m -- %d -- \e[0m'
zstyle ':completion:*:descriptions' format $'\e[1;33m -- %d -- \e[0m'
zstyle ':completion:*:messages'     format $'\e[1;35m -- %d -- \e[0m'
zstyle ':completion:*:warnings'     format $'\e[1;31m -- No Matches Found -- \e[0m'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-tilde-:*' group-order named-directories users
zstyle ':completion:*' last-prompt true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z} r:|[._-]=* r:|=*'
zstyle ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt $'\e[1;35;40m%SSelect: lines: %L matches: %M [%p]\e[0m'
zstyle ':completion:*' select-scroll true
zstyle ':completion:*' special-dirs false
zstyle ':completion:*' verbose yes

zstyle ':completion:*:*:kill:*:*' command 'ps xf -U $USER -o pid,%cpu,cmd'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;32'

#------------------------------
# User Function
#------------------------------
# support colors in less
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;35;40m\e[7m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m' 

# adds sudo to the line
sudo-command-line() {
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
    zle end-of-line
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line
