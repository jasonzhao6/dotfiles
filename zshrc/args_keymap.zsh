source "$ZSHRC_DIR/args.history.zsh"; args_init

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

ARGS_SOFT_SELECT='Soft-select the 1st column by inserting a `#` before the 2nd column'

function a {
	local namespace='a'
	keymap $namespace ${#ARGS_KEYMAP} "${ARGS_KEYMAP[@]}" "$@"
}

#
# Key mappings (alphabetized)
#

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
		args_history

	# Otherwise, go to the specified index, then list args
	else
		# shellcheck disable=SC2034
		ARGS_CURSOR=$go_to_index
		aa
	fi
}

function au {
	args_undo_selection
}

function ar {
	args_redo
	args_list
	args_redo_bar
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
