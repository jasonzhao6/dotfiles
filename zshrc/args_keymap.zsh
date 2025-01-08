#
# Namespace: [A]rgs
#

ARGS_KEYMAP=(
	'a·s # Save args'
	'a·s <match>* <-mismatch>* # Save args & filter'
	''
	'a·so # Save args & soft-select the 1st column'
	'a·so <match>* <-mismatch>* # Save args & soft-select the 1st column & filter'
	''
	'a·a # List args'
	'a·a <match>* <-mismatch>* # Filter args'
	''
	'a·z # Undo change'
	'a·Z # Redo change'
	''
	'a·h # List history entries'
	'a·h <index> # Select history entry'
	'a·0 # Reset history'
)

function a {
	keymap a ${#ARGS_KEYMAP} "${ARGS_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/args_helpers.zsh"
source "$ZSHRC_DIR/args_history.zsh"; args_history_init

# Constants
# shellcheck disable=SC2034
ARGS_EMPTY='(empty)'
ARGS_SOFT_SELECT='Soft-select the 1st column by inserting a `#` before the 2nd column'

# States
ARGS_USED_TOP_ROW=

function a0 {
	args_history_reset
}

# shellcheck disable=SC2120
function aa {
	local filters=("$@")

	# If there is no `filters`, list args
	if [[ -z "${filters[*]}" ]]; then
		args_list

	# Otherwise, apply `filters`, then list args
	else
		args_plain | args_filter "${filters[@]}" | as
	fi
}

function ah {
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

function as {
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

function aso {
	local filters=("$@")
	as "$ARGS_SOFT_SELECT" "${filters[@]}"
}

function az {
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

function aZ {
	args_history_redo
	args_list
	args_history_redo_error_bar
}
