#
# Config
#

export GREP_COLOR='1;32'
export PCREGREP_COLOR='1;32'
export LSCOLORS='gxcxbxexfxegedabagaced'
export JQ_COLORS='1;35:1;35:1;35:1;35:1;32:1;33:1;33:1;36' # v1.7+

#
# Modes
#

function color {
	alias diff='colordiff'
	alias grep='grep --color=always'
	alias egrep='egrep --color=always'
	alias pgrep='pcregrep --color=always'
	alias ls='ls --color=always'
};

function no_color {
	unalias diff
	unalias grep
	unalias egrep
	unalias pgrep
	unalias ls
}

#
# Colors
#

# Foregrounds
function black_fg { echo "\e[30m$*\e[0m"; }
function red_fg { echo "\e[31m$*\e[0m"; }
function green_fg { echo "\e[32m$*\e[0m"; }
function yellow_fg { echo "\e[33m$*\e[0m"; }
function blue_fg { echo "\e[34m$*\e[0m"; }
function magenta_fg { echo "\e[35m$*\e[0m"; }
function cyan_fg { echo "\e[36m$*\e[0m"; }
function white_fg { echo "\e[37m$*\e[0m"; }
function gray_fg { echo "\e[90m$*\e[0m"; }

# Backgrounds
function black_bg { echo "\e[40m$*\e[0m"; }
function red_bg { echo "\e[41m$*\e[0m"; }
function green_bg { echo "\e[42m$*\e[0m"; }
function yellow_bg { echo "\e[43m$*\e[0m"; }
function blue_bg { echo "\e[44m$*\e[0m"; }
function magenta_bg { echo "\e[45m$*\e[0m"; }
function cyan_bg { echo "\e[46m$*\e[0m"; }
function white_bg { echo "\e[47m$*\e[0m"; }

# Red error bar (Background color + padding on both sides)
function red_bar { echo "\e[41m  $*  \e[0m"; }
