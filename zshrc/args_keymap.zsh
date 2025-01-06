source "$ZSHRC_DIR/args.history.zsh"; args_init

#
# Namespace: [A]rgs
#

ARGS_KEYMAP=(
	'a s # Save as args'
	'a so # Save as args & soft-select the 1st column'
	''
	'a a <substring>* -<substring>*'
	''
	'a h'
	'a u'
	'a r'
)

ARGS_SOFT_SELECT='Soft-select the 1st column by inserting a `#` before the 2nd column'

function a {
	echo a ARGS_CURSOR: "$ARGS_CURSOR"
	if [[ -t 0 ]]; then
		# When not invoked after a `|`
		local namespace='a'
		keymap $namespace ${#ARGS_KEYMAP} "${ARGS_KEYMAP[@]}" "$@"
	else
		# When invoked after a `|`
		local key=$1
		[[ $key == so ]] && args_save "$ARGS_SOFT_SELECT" || args_save
	fi
	echo a ARGS_CURSOR: "$ARGS_CURSOR"
}

#function aa { a_a "$@"; }

#
# Key mappings
#

# TODO
function a_a {
	if [[ -z $1 ]]; then
		args_list
	else
		args_plain | eval "$(args_filtering "$@") | $(args_coloring "$@")" | a_s
	fi
}

# TODO
function a_h {
	if [[ -z $1 || $1 -lt $ARGS_TAIL || $1 -gt $ARGS_HEAD ]]; then
		args_history
	else
		# shellcheck disable=SC2034
		ARGS_CURSOR=$1
		a_a
	fi
}

# TODO changes to history env vars seem stuck in subshell
function a_u {
	echo a_u ARGS_CURSOR: "$ARGS_CURSOR"
	args_undo_selection
	echo a_u ARGS_CURSOR: "$ARGS_CURSOR"
}

# TODO
function a_r { args_redo; args_list; args_redo_bar; }

function a_s {
	local is_soft_select=$1
	eval "$(prev_command)" | args_save "$is_soft_select"
}

function a_so {
	a_s "$ARGS_SOFT_SELECT"
}
