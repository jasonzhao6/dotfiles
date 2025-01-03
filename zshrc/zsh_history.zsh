# shellcheck disable=SC2034

# Config
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# List / filter
# (e.g `h` to list all, `h foo` to filter)
# shellcheck disable=SC2196
function h { egrep --ignore-case "$*" "$HISTFILE" | trim 15 | sort --unique | ss; }

# [C]lear
function hc { rm "$HISTFILE"; }

# Edit
function hm { mate "$HISTFILE"; }

# Session persistence
function h0 { unset -f zshaddhistory; }              #  disk &&  memory
function h1 { function zshaddhistory { return 1; }; } # !disk && !memory
function h2 { function zshaddhistory { return 2; }; } # !disk &&  memory
