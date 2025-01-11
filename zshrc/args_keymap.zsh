ARGS_NAMESPACE='args_keymap'
ARGS_ALIAS='a'

ARGS_KEYMAP=(
	"$ARGS_ALIAS·s # Save args"
	"$ARGS_ALIAS·s <match>* <-mismatch>* # Save args & filter"
	''
	"$ARGS_ALIAS·so # Save args & soft-select the 1st column"
	"$ARGS_ALIAS·so <match>* <-mismatch>* # Save args & soft-select the 1st column & filter"
	''
	"$ARGS_ALIAS·a # List args"
	"$ARGS_ALIAS·a <match>* <-mismatch>* # Filter args"
	''
	"$ARGS_ALIAS·u # Undo change"
	"$ARGS_ALIAS·r # Redo change"
	''
	"$ARGS_ALIAS·h # List history entries"
	"$ARGS_ALIAS·h <index> # Select history entry"
	"$ARGS_ALIAS·0 # Reset history"
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

# States
ARGS_USED_TOP_ROW=

function args_keymap_0 {
	args_history_reset
}

# shellcheck disable=SC2120
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

function args_keymap_h {
	local index=$1

	# If `index` is not specified, list all history entries
	[[ -z $index ]] && args_history_entries && return

	# If `index` is within range, set it as the index, then list args
	if [[ $(args_history_is_index_valid "$index") -eq 1 ]]; then
		# shellcheck disable=SC2034
		ARGS_HISTORY_INDEX=$index
		aa

	# Otherwise, list all history entries and show error bar
	else
		args_history_entries
		echo
		red_bar "Index out of range: $index"
	fi
}

function args_keymap_r {
	args_history_redo
	args_list
	args_history_redo_error_bar
}

function args_keymap_s {
	# Users see the interface of `as` as `as <match>* <-mismatch>*`
	# Only `as` sees the `as` as `as <is soft select> <match>* <-mismatch>*`
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
