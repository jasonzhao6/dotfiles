#
# Config
#

export GREP_COLOR='1;32'
export LSCOLORS='gxcxbxexfxegedabagaced'
export JQ_COLORS='1;35:1;35:1;35:1;35:1;32:1;33:1;33:1;36' # v1.7+

#
# Modes
#

function color {
	alias diff='colordiff'
	alias egrep='egrep --color=always'
	alias grep='grep --color=always'
	alias ls='ls --color=always'
};

function no_color {
	unalias diff
	unalias egrep
	unalias grep
	unalias ls
}

#
# Setters
#

# Set foreground
function cyan_fg { echo "\e[36m$*\e[0m"; }
function gray_fg { echo "\e[90m$*\e[0m"; }

# Set foreground by use case
BACKTICK="\e[90m\`\e[0m"
function command_color { echo "$BACKTICK$(cyan_fg "$@")$BACKTICK"; }
function command_color_dim { echo "$BACKTICK$(gray_fg "$@")$BACKTICK"; }
function grep_color { echo "\e[1;32m\e[K$*\e[m\e[K"; }

# Set background
function red_bg { echo "\e[41m$*\e[0m"; }
function green_bg { echo "\e[42m$*\e[0m"; }
