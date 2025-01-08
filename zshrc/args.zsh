#source "$ZSHRC_DIR/args_history.zsh"; args_history_init
#
#### [Args]
## [s]ave into args history
## (e.g `seq 100 105; s`, or alternatively `seq 100 105 | s`)
#function s { ss "Insert `#` after the first column to soft-select it"; }
#function ss { [[ -t 0 ]] && eval "$(prev_command)" | args_save "$@" || args_save "$@"; }
## paste into args history
## (e.g copy a list into pasteboard, then `v`)
#function v { pbpaste | s; }
#function vv { pbpaste | as; }
## list / filter [a]rgs
## (e.g `a` to list all, `a foo and bar -not -baz` to filter)
## shellcheck disable=SC2120
#function a { [[ -z $1 ]] && args_list || { args_plain | eval "$(args_filtering "$@") | $(args_coloring "$@")" | as; }; }
## select a random arg
## (e.g `aa echo`)
#function aa { arg $((RANDOM % $(args_list_size) + 1)) "$@"; }
## select an [arg] by number
## (e.g `arg <number> echo`, or with explicit positioning `arg <number> echo ~~`)
#function arg { args_use_selection "$@"; }
#function 1 { arg "$0" "$@"; }
#function 2 { arg "$0" "$@"; }
#function 3 { arg "$0" "$@"; }
#function 4 { arg "$0" "$@"; }
#function 5 { arg "$0" "$@"; }
#function 6 { arg "$0" "$@"; }
#function 7 { arg "$0" "$@"; }
#function 8 { arg "$0" "$@"; }
#function 9 { arg "$0" "$@"; }
#function 10 { arg "$0" "$@"; }
#function 11 { arg "$0" "$@"; }
#function 12 { arg "$0" "$@"; }
#function 13 { arg "$0" "$@"; }
#function 14 { arg "$0" "$@"; }
#function 15 { arg "$0" "$@"; }
#function 16 { arg "$0" "$@"; }
#function 17 { arg "$0" "$@"; }
#function 18 { arg "$0" "$@"; }
#function 19 { arg "$0" "$@"; }
#function 20 { arg "$0" "$@"; }
#function 0 { arg $ "$@"; } # last arg
## select args within a rang[e]
## (e.g `e 2 5 echo`, or with explicit positioning `e 2 5 echo ~~ and ~~ again`)
#function e { for i in $(seq "$1" "$2"); do echo; arg "$i" "${@:3}"; done; }
## select all args via an iterator
## (e.g `each echo`, `all echo`, `map echo '$((~~ * 2))'`)
#function each { for i in $(seq 1 "$(args_list_size)"); do echo; arg "$i" "$@"; done; }
#function all { for i in $(seq 1 "$(args_list_size)"); do echo; arg "$i" "$@" & done; wait; }
#function map { local map=''; local row; for i in $(seq 1 "$(args_list_size)"); do echo; row=$(arg "$i" "$@"); echo "$row"; map+="$row\n"; done; echo; echo "$map" | as; }
## list / filter colum[n] by letter
## (e.g `n` to list all, `n d` to keep only the fourth column, delimited based on the bottom row)
#function n { args_select_column 0 "$1"; }
## (`nn` is like `n`, but delimited based on the top row)
#function nn { args_select_column 1 "$1"; }
## [c]opy into pasteboard
## (e.g `c` to copy all args, `11 c` to copy only the eleventh arg)
#function c { [[ -z $1 ]] && args_plain | pbcopy || echo -n "$@" | pbcopy; }
## [y]ank / [p]ut current args into a different tab
#function y { args > ~/.zshrc.args; }
#function p { echo "$(<~/.zshrc.args)" | as; }
## [u]ndo / [r]edo changes, up to `ARGS_HISTORY_MAX`
#function u { args_history_undo_selection; }
#function r { args_history_redo; args_list; args_history_redo_error_bar; }
## list / select historical args by [i]ndex
## (e.g `i` to list history, `i 8` to select the args at index 8)
#function i { [[ -z $1 || $1 -lt $ARGS_TAIL || $1 -gt $ARGS_HEAD ]] && args_history_entries || { ARGS_HISTORY_INDEX=$1; a; }; }
