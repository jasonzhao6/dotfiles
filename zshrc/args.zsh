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

## select an [arg] by number
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
