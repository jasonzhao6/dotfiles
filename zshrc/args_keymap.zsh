source "$ZSHRC_DIR/args.history.zsh"; args_history_init

#
# Namespace: [A]rgs
#

ARGS_KEYMAP=(
	'a•s # Save as args'
	'a•so # Save as args & soft-select the 1st column'
	''
	'a•a <substring>* -<substring>*'
	''
	'a•h'
	'a•u'
	'a•r'
)
# TODO dim and explain • if it works well

function a {
	local namespace='a'
	keymap $namespace ${#ARGS_KEYMAP} "${ARGS_KEYMAP[@]}" "$@"
}

#
# Key mappings (alphabetized)
#

# Constants
ARGS_SOFT_SELECT='Soft-select the 1st column by inserting a `#` before the 2nd column'

# States
ARGS_USED_TOP_ROW=

# shellcheck disable=SC2120
function aa {
	local filters=$1

	# If there is no `filters`, list args
	if [[ -z $filters ]]; then
		args_list

	# Otherwise, apply `filters`, then list args
	else
		args_plain | eval "$(args_filtering "$filters") | $(args_coloring "$filters")" | as
	fi
}

function ah {
	local go_to_index=$1

	# If there is not a valid `go_to_index`, list history
	if [[ -z $go_to_index || $go_to_index -lt $ARGS_TAIL || $go_to_index -gt $ARGS_HEAD ]]; then
		args_history_inspect

	# Otherwise, go to the specified index, then list args
	else
		# shellcheck disable=SC2034
		ARGS_CURSOR=$go_to_index
		aa
	fi
}

function au {
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

function ar {
	args_history_redo
	args_list
	args_history_redo_error_bar
}

function as {
	local is_soft_select=$1

	# When invoked as standalone command
	if [[ -t 0 ]]; then
		eval "$(prev_command)" | args_save "$is_soft_select"

	# When invoked after a pipe `|`
	else
		args_save "$is_soft_select"
	fi

}

function aso {
	as "$ARGS_SOFT_SELECT"
}
