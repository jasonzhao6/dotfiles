source "$ZSHRC_DIR/args.history.zsh"; args_init

#
# Namespace: [A]rgs
#

ARGS_KEYMAP=(
	'a s # Save as args'
	'a so # Save as args & soft-select the 1st column'
	''
	'a a <substring>* -<substring>* # TODO'
	''
	'a h'
)

ARGS_SOFT_SELECT='Soft-select the 1st column by inserting a `#` before the 2nd column'

function a {
	if [[ -t 0 ]]; then
		# When not invoked after a `|`
		local namespace='a'
		keymap $namespace ${#ARGS_KEYMAP} "${ARGS_KEYMAP[@]}" "$@"
	else
		# When invoked after a `|`
		local key=$1
		[[ $key == so ]] && args_save "$ARGS_SOFT_SELECT" || args_save
	fi
}

#
# Key mappings
#

# TODO
function a_a {
	if [[ -z $1 ]]; then
		echo if
		args_list
	else
		echo else
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

function a_s {
	local is_soft_select=$1
	eval "$(prev_command)" | args_save "$is_soft_select"
}

function a_so {
	a_s "$ARGS_SOFT_SELECT"
}
