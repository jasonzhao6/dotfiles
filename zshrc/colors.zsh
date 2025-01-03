#
# Color modes
#

function color {
    alias diff='colordiff'
    alias egrep='egrep --color=always'
    alias grep='grep --color=always'
    alias ls='ls --color=always'
};

function bw { # black and white
    unalias diff
    unalias egrep
    unalias grep
    unalias ls
}

#
# Color configs
#

export GREP_COLOR='1;32'
export LSCOLORS='gxcxbxexfxegedabagaced'
export JQ_COLORS='1;35:1;35:1;35:1;35:1;32:1;33:1;33:1;36' # v1.7+

#
# Color setters
#

# set foreground
function cyan-fg { echo "\e[36m$*\e[0m"; }
function gray-fg { echo "\e[90m$*\e[0m"; }

# set foreground by use case
BACKTICK="\e[90m\`\e[0m"
function command-color { echo "$BACKTICK$(cyan-fg "$@")$BACKTICK"; }
function command-color-dim { echo "$BACKTICK$(gray-fg "$@")$BACKTICK"; }
function grep-color { echo "\e[1;32m\e[K$*\e[m\e[K"; }

# set background
function red-bg { echo "\e[41m$*\e[0m"; }
function green-bg { echo "\e[42m$*\e[0m"; }
