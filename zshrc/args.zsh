#source "$ZSHRC_DIR/args.history.zsh"; args_init
#
#### [Args]
## [s]ave into args history
## (e.g `seq 100 105; s`, or alternatively `seq 100 105 | s`)
#function s { ss "Insert '#' after the first column to soft-select it"; }
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
#function u { args_undo_selection; }
#function r { args_redo; args_list; args_redo_bar; }
## list / select historical args by [i]ndex
## (e.g `i` to list history, `i 8` to select the args at index 8)
#function i { [[ -z $1 || $1 -lt $ARGS_TAIL || $1 -gt $ARGS_HEAD ]] && args_history || { ARGS_CURSOR=$1; a; }; }

#
# Getters
#

function args { echo "${ARGS_HISTORY[$ARGS_CURSOR]}"; }
function args_plain { args | bw | expand; }
function args_list { args | nl; }
function args_list_plain { args | nl | bw | expand; }
function args_list_size { args | wc -l; }
function args_coloring { echo "egrep --color=always --ignore-case '${${@:#-*}// /|}'"; }

function args_filtering {
	local filters

	# Expand each argument into a separate `grep` filter to allow matching out-of-order
	filters="grep ${*// / | grep }"

	# Treat any argument with a leading `-` as a negative match
	filters=${filters// -/ --invert-match }

	# Do not add coloring yet as coloring from a previous `grep` can mess up the next `grep`
	# `args_coloring` will add coloring for all positive matches immediately after `args_filtering`
	filters=${filters//grep/grep --color=never --ignore-case}

	echo "$filters"
}

function args_columns {
	# Whether to delimit based on the top row vs the bottom row
	local use_top_row=$1

	# Skip the `nl` column, then start accumulating `columns` starting with `current_column`
	local skip_nl_column=1
	local current_column=a
	local columns=''

	if [[ ${use_top_row} -eq 1 ]]; then
		row=$(args_list_plain | head -1)
	else
		row=$(args_list_plain | tail -1)
	fi

	for i in $(seq 1 ${#row}); do
		# A new column starts when transitioning from a space to a non-space character
		if [[ ${row[$i-1]} == ' ' && ${row[$i]} != ' ' ]]; then
			# Skip the `nl` column
			if [[ $skip_nl_column -eq 1 ]]; then
				skip_nl_column=0
				columns+=' '
			else
				columns+=$current_column
				current_column=$(next_ascii $current_column)
			fi
		else
			columns+=' '
		fi
	done

	echo "$columns"
}

function args_columns_bar {
	local use_top_row=$1

	green_bg "$(args_columns "$use_top_row")"
}

#
# Setters
#

# Call this function with a pipe to save the args
function args_save {
	local new_args; new_args=$(cat - | head -1000 | compact)

	# Insert '#' after the first column to soft-select it
	[[ -n $1 ]] && new_args=$(echo "$new_args" | insert_hash)

	if [[ -n "$new_args" ]]; then
		local new_args_plain; new_args_plain=$(echo "$new_args" | bw | expand)

		if [[ "$new_args_plain" != $(args_plain) ]]; then
			args_push "$ARGS"

			# Set global states used by `n, nn, u`
			ARGS_PUSHED=1
			ARGS_USED_TOP_ROW=
		else
			# Set global states used by `n, nn`
			ARGS_PUSHED=0
		fi

		# Always replace the args; sometimes content is the same, but grep coloring is different
		args_replace "$new_args"
		args_list
	fi
}

function args_use_selection {
	if [[ -n $1 && -n $2 ]]; then
		local row; row="$(args_plain | sed -n "$1p" | sed 's/ *#.*//' | strip)"

		if [[ $(index_of "${(j: :)@}" '~~') -eq 0 ]]; then
			echo_eval "${*:2} $row"
		else
			echo_eval ${${*:2}//~~/$row}
		fi
	fi
}

function args_select_column {
	local use_top_row=$1
	local selected_column=$2

	if [[ -z $2 ]]; then
		args_list
		args_columns_bar "$use_top_row"
	else
		local columns; columns=$(args_columns "$use_top_row")
		local first_column; first_column=$(index_of "$columns" a)
		local target_column; target_column=$(index_of "$columns" "$selected_column")
		local next_column; next_column=$(index_of "$columns" "$(next_ascii "$selected_column")")
		local column_start; column_start=$([[ "$target_column" -ne 0 ]] && echo "$target_column" || echo "$first_column")
		local column_end; column_end=$([[ "$next_column" -ne 0 ]] && echo $((next_column - 1)))

		args_list_plain | cut -c "$column_start"-"$column_end" | strip_right | as

		# If a column was not selected, show columns bar again for convenience
		if [[ $ARGS_PUSHED -eq 0 && $(index_of "$(args_columns "$use_top_row")" b) -ne 0 ]]; then
			args_columns_bar "$use_top_row"
		fi

		# Set global states used by `u`
		ARGS_USED_TOP_ROW=$use_top_row
	fi
}
