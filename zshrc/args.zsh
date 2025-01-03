# TODO

source "$ZSHRC_DIR/args.history.zsh"; args_init

### [Args]
# [s]ave into args history
# (e.g `seq 100 105; s`, or alternatively `seq 100 105 | s`)
function s { ss 'Insert `#` after the first column to soft-select it' }
function ss { [[ -t 0 ]] && eval $(prev_command) | args_save $@ || args_save $@ }
# paste into args history
# (e.g copy a list into pasteboard, then `v`)
function v { pbpaste | s }
function vv { pbpaste | ss }
# list / filter [a]rgs
# (e.g `a` to list all, `a foo and bar -not -baz` to filter)
function a { [[ -z $1 ]] && args-list || { args-build-greps! $@; args-plain | eval "$ARGS_FILTERS | $ARGS_COLOR" | ss } }
# select a random arg
# (e.g `aa echo`)
function aa { arg $((RANDOM % $(args-list-size) + 1)) $@ }
# select an [arg] by number
# (e.g `arg <number> echo`, or with explicit positioning `arg <number> echo ~~`)
function arg { [[ -n $1 && -n $2 ]] && { ARG="$(args-plain | sed -n "$1p" | sed 's/ *#.*//' | strip)"; [[ $(index_of ${(j: :)@} '~~') -eq 0 ]] && { echo_eval "${@:2} $ARG"; return 0 } || echo_eval ${${@:2}//~~/$ARG} } }
function 1 { arg $0 $@ }
function 2 { arg $0 $@ }
function 3 { arg $0 $@ }
function 4 { arg $0 $@ }
function 5 { arg $0 $@ }
function 6 { arg $0 $@ }
function 7 { arg $0 $@ }
function 8 { arg $0 $@ }
function 9 { arg $0 $@ }
function 10 { arg $0 $@ }
function 11 { arg $0 $@ }
function 12 { arg $0 $@ }
function 13 { arg $0 $@ }
function 14 { arg $0 $@ }
function 15 { arg $0 $@ }
function 16 { arg $0 $@ }
function 17 { arg $0 $@ }
function 18 { arg $0 $@ }
function 19 { arg $0 $@ }
function 20 { arg $0 $@ }
function 0 { arg $ $@ } # last arg
# select args within a rang[e]
# (e.g `e 2 5 echo`, or with explicit positioning `e 2 5 echo ~~ and ~~ again`)
function e { for i in $(seq $1 $2); do echo; arg $i ${${@:3}}; done }
# select all args via an iterator
# (e.g `each echo`, `all echo`, `map echo '$((~~ * 2))'`)
function each { ARGS_ROW_SIZE=$(args-list-size); for i in $(seq 1 $ARGS_ROW_SIZE); do echo; arg $i $@; done }
function all { ARGS_ROW_SIZE=$(args-list-size); for i in $(seq 1 $ARGS_ROW_SIZE); do echo; arg $i $@ &; done; wait }
function map { ARGS_ROW_SIZE=$(args-list-size); ARGS_MAP=''; for i in $(seq 1 $ARGS_ROW_SIZE); do echo; ARG=$(arg $i $@); echo $ARG; ARGS_MAP+="$ARG\n"; done; echo; echo $ARGS_MAP | ss }
# list / filter colum[n] by letter
# (e.g `n` to list all, `n d` to keep only the fourth column, delimited based on the bottom row)
function n { args_select_column $@ }
# (`nn` is like `n`, but delimited based on the top row)
function nn { ARGS_USE_TOP_ROW=1 n $@ }
# [c]opy into pasteboard
# (e.g `c` to copy all args, `11 c` to copy only the eleventh arg)
function c { [[ -z $1 ]] && args-plain | pbcopy || echo -n $@ | pbcopy }
# [y]ank / [p]ut current args into a different tab
function y { args > ~/.zshrc.args }
function p { echo "$(<~/.zshrc.args)" | ss }
# [u]ndo / [r]edo changes, up to `ARGS_HISTORY_MAX`
function u { ARG_SIZE_PREV=$(args-columns | strip); args_undo; args-list; args_undo_bar; ARG_SIZE_CURR=$(args-columns | strip); [[ -n $N && ${#ARG_SIZE_PREV} -lt ${#ARG_SIZE_CURR} ]] && args-columns-bar }
function r { args_redo; args-list; args_redo_bar }
# list / select historical args by [i]ndex
# (e.g `i` to list history, `i 8` to select the args at index 8)
function i { [[ -z $1 || $1 -lt $ARGS_TAIL || $1 -gt $ARGS_HEAD ]] && args_history || { ARGS_CURSOR=$1; a } }
# helpers
function args { echo $ARGS_HISTORY[$ARGS_CURSOR] }
function args-plain { args | no_color | expand }
function args-list { args | nl }
function args-list-plain { args | nl | no_color | expand }
function args-list-size { args | wc -l | awk '{print $1}' }
function args-columns { ARGS_COLUMNS=''; ARGS_COL_CURR=a; ARGS_SKIP_NL=1; args-pick-header! $@; for i in $(seq 1 ${#ARG}); do args-label-column! $i; done; echo $ARGS_COLUMNS }
function args-columns-bar { green-bg "$(args-columns $1)" }
# helpers! (`!` means the function sets env vars to be consumed by its caller)
function args-build-greps! { ARGS_FILTERS="grep ${*// / | grep }"; ARGS_FILTERS=${ARGS_FILTERS// -/ --invert-match }; ARGS_FILTERS=${ARGS_FILTERS//grep/grep --color=never --ignore-case}; ARGS_COLOR="egrep --color=always --ignore-case '${${@:#-*}// /|}'" }
function args-pick-header! { [[ -z ${1:-$ARGS_USE_BOTTOM_ROW} || ${1:-$ARGS_USE_BOTTOM_ROW} -eq 1 ]] && ARG=$(args-list-plain | tail -1) || ARG=$(args-list-plain | head -1) }
function args-label-column! { [[ $ARG[$1-1] == ' ' && $ARG[$1] != ' ' ]] && { [[ $ARGS_SKIP_NL -eq 1 ]] && { ARGS_SKIP_NL=0; ARGS_COLUMNS+=' ' } || { ARGS_COLUMNS+=$ARGS_COL_CURR; ARGS_COL_CURR=$(next_ascii $ARGS_COL_CURR) } } || ARGS_COLUMNS+=' ' }
function args-mark-references! { ARGS_USE_BOTTOM_ROW=$2; ARGS_COLUMNS=$(args-columns $2); ARGS_COL_FIRST=$(index_of $ARGS_COLUMNS a); ARGS_COL_TARGET=$(index_of $ARGS_COLUMNS $1); ARGS_COL_NEXT=$(index_of $ARGS_COLUMNS $(next_ascii $1)) }
function args-select-column! { args-list-plain | cut -c $([[ $ARGS_COL_TARGET -ne 0 ]] && echo $ARGS_COL_TARGET || echo $ARGS_COL_FIRST)-$([[ $ARGS_COL_NEXT -ne 0 ]] && echo $((ARGS_COL_NEXT - 1))) | strip_right | ss }

#
# Helpers
#

function args_select_column {
	[[ $ARGS_USE_TOP_ROW -eq 1 ]] && N=0 || N=1
	if [[ -z $1 ]]; then
		args-list
		args-columns-bar $N
	else
		args-mark-references! $1 $N
		_N=$N
		args-select-column!
		N=$_N

		if [[ $ARGS_PUSHED -eq 0 && $(index_of "$(args-columns $N)" b) -ne 0 ]]; then
			args-columns-bar $N
		fi
	fi
}

# | after a list
function args_save {
	local new_args; new_args=$(cat - | head -1000 | no_empty)

	# Insert `#` after the first column to soft-select it
	[[ -n $1 ]] && new_args=$(echo $new_args | insert_hash)

	if [[ -n $new_args ]]; then
		local new_args_plain; new_args_plain=$(echo $new_args | no_color | expand)

		if [[ $new_args_plain != $(args-plain) ]]; then
			args_push $ARGS
			ARGS_PUSHED=1
			N= # TODO rename
		else
			ARGS_PUSHED=0
		fi

		# Always replace the args; sometimes content is the same, but grep coloring is different
		args_replace $new_args
		args-list
	fi
}
