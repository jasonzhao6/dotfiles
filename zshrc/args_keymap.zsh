ARGS_NAMESPACE='args_keymap'
ARGS_ALIAS='a'

ARGS_KEYMAP=(
	"$ARGS_ALIAS·s # Save as args"
	"$ARGS_ALIAS·s <matches>* -<mismatches>* # Save as args & filter"
	"$ARGS_ALIAS·so # Save as args & soft-select the 1st column"
	"$ARGS_ALIAS·so <matches>* -<mismatches>* # Save as args & soft-select the 1st column & filter"
	''
	"$ARGS_ALIAS·ny <command> ~~? # Use a random arg"
	"$ARGS_ALIAS·n <number> <command> ~~? # Use an arg by number"
	"$ARGS_ALIAS·q <start> <finish> <command> ~~? # Use args within a sequence"
	"$ARGS_ALIAS·e <command> ~~? # Use each arg in series"
	"$ARGS_ALIAS·l <command> ~~? # Use all args in parallel"
	"$ARGS_ALIAS·m <command> ~~? # Map args, e.g \`seq 1 10 | as; am echo '\$((~~ * 10))'\`"
	''
	"$ARGS_ALIAS·a # List all args"
	"$ARGS_ALIAS·a <matches>* -<mismatches>* # Filter args"
	"$ARGS_ALIAS·d # Delimit columns via the bottom row"
	"$ARGS_ALIAS·d <letter> # Select column by letter"
	"$ARGS_ALIAS·dt # Delimit columns via the top row"
	"$ARGS_ALIAS·dt <letter> # Select column by letter"
	''
	"$ARGS_ALIAS·u # Undo \"Filter args\" or \"Select column\""
	"$ARGS_ALIAS·r # Redo \"Filter args\" or \"Select column\""
	"$ARGS_ALIAS·h # List all history entries"
	"$ARGS_ALIAS·h <index> # Select a history entry by index"
	"$ARGS_ALIAS·hc # Reset history"
	''
	"$ARGS_ALIAS·c # Copy all args into pasteboard"
	"$ARGS_ALIAS·c <number> # Copy an arg by number into pasteboard"
	"$ARGS_ALIAS·y # Yank all args to put into a different tab"
	"$ARGS_ALIAS·p # In a different tab, put args"
)

keymap_init $ARGS_NAMESPACE $ARGS_ALIAS "${ARGS_KEYMAP[@]}"

function args_keymap {
	keymap_invoke $ARGS_NAMESPACE $ARGS_ALIAS ${#ARGS_KEYMAP} "${ARGS_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/args_helpers.zsh"
source "$ZSHRC_DIR/args_history.zsh"; args_history_init

# Constants
ARGS_SOFT_SELECT='Soft-select the 1st column by inserting a `#` before the 2nd column'
ARGS_YANK_FILE="$HOME/.zshrc.args"

# States
# shellcheck disable=SC2034
ARGS_PUSHED=
ARGS_USED_TOP_ROW=

function args_keymap_a {
	local filters=("$@")

	# If there is no `filters`, list args
	if [[ -z "${filters[*]}" ]]; then
		args_list

	# Otherwise, apply `filters`, then list args
	else
		args_plain | args_filter "${filters[@]}" | as
	fi
}

function args_keymap_c {
	local string=$*

	if [[ -z $string ]]; then
		args_plain | pbcopy
	else
		echo -n "$string" | pbcopy
	fi
}

function args_keymap_d {
	local index=$1

	args_select_column 0 "$index"
}

function args_keymap_dt {
	local index=$1

	args_select_column 1 "$index"
}

function args_keymap_e {
	local command=$*

	for number in $(seq 1 "$(args_size)"); do
		echo
		args_keymap_n "$number" "$command"
	done
}

function args_keymap_h {
	local index=$1

	# If `index` is not specified, list history entries
	[[ -z $index ]] && args_history_entries && return

	# If `index` was set successfully, then list args at `index`
	if args_history_set_index "$index"; then
		aa

	# Otherwise, list history entries again and show error bar
	else
		args_history_entries
		echo
		red_bar "Index out of range: $index"
	fi
}

function args_keymap_hc {
	args_history_reset
}

function args_keymap_l {
	local command=$*

	for number in $(seq 1 "$(args_size)"); do
		echo
		args_keymap_n "$number" "$command" &
	done

	wait
}

function args_keymap_m {
	local command=$*

	local map=''
	local row

	for number in $(seq 1 "$(args_size)"); do
		echo
		row=$(args_keymap_n "$number" "$command")
		map+="$row\n"
		echo "$row"
	done

	echo
	echo "$map" | as
}

function args_keymap_n {
	local number=$1; shift
	local command=$*

	if [[ -n $number && -n $command ]]; then
		local row; row="$(args_plain | sed -n "${number}p" | sed 's/ *#.*//' | strip)"

		if [[ $command != *'~~'* ]]; then
			echo_eval "$command $row"
		else
			echo_eval "${command//~~/$row}"
		fi
	fi
}

function args_keymap_ny {
	local command=$*

	args_keymap_n $((RANDOM % $(args_size) + 1)) "$command"
}

function args_keymap_p {
	echo "$(<"$ARGS_YANK_FILE")" | as
}

function args_keymap_q {
	local start=$1; shift
	local finish=$1; shift # `end` is a reserved keyword
	local command=$*

	for number in $(seq "$start" "$finish"); do
		echo
		args_keymap_n "$number" "$command"
	done
}

function args_keymap_r {
	args_history_redo
	args_list
	args_history_redo_error_bar
}

function args_keymap_s {
	# Users see the interface of this mapping as `s <matches>* -<mismatches>*`
	# Only `so` know this interface as `s <is_soft_select> <matches>* -<mismatches>*`
	local is_soft_select=$1
	[[ $is_soft_select == "$ARGS_SOFT_SELECT" ]] && shift || is_soft_select=0

	local filters=("$@")

	# When invoked as standalone command
	if [[ -t 0 ]]; then
		eval "$(prev_command)" | args_save "$is_soft_select" "${filters[@]}"

	# When invoked after a pipe `|`
	else
		args_save "$is_soft_select" "${filters[@]}"
	fi

}

function args_keymap_so {
	local filters=("$@")

	as "$ARGS_SOFT_SELECT" "${filters[@]}"
}

function args_keymap_u {
	local column_size_before; column_size_before=$(args_columns "$ARGS_USED_TOP_ROW" | strip)

	args_history_undo
	args_list
	args_history_undo_error_bar

	local column_size_after; column_size_after=$(args_columns "$ARGS_USED_TOP_ROW" | strip)

	# If undoing a column selection, show the columns bar for convenience
	if [[ -n $ARGS_USED_TOP_ROW && ${#column_size_before} -lt ${#column_size_after} ]]; then
		args_columns_bar "$ARGS_USED_TOP_ROW"
	fi
}

function args_keymap_y {
	args_history_current > "$ARGS_YANK_FILE"
}
