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

function a {
	local namespace='a'
	keymap $namespace ${#ARGS_KEYMAP} "${ARGS_KEYMAP[@]}" "$@"
	echo exit code: $?
}

#
# Key mappings
#

function a_a {
	if [[ -z $1 ]]; then
		echo if
		args_list
	else
		echo else
		args_plain | eval "$(args_filtering "$@") | $(args_coloring "$@")" | a s
	fi
}

function a_h {
	if [[ -z $1 || $1 -lt $ARGS_TAIL || $1 -gt $ARGS_HEAD ]]; then
		args_history
	else
		ARGS_CURSOR=$1
		a a
	fi
}

function a_s {
	if [[ -t 0 ]]; then
		# Save the output of the previous command
		eval "$(prev_command)" | args_save "$@"
	else
		# Save the output of the upstream `|` command
		args_save "$@"
	fi
}

function a_so() {
	a s 'Soft-select the 1st column by inserting a `#` before the 2nd column'
}
