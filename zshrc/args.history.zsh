#
# Args history (via a circular buffer)
#

# Visualize
#
#              123456789
#   cursor     ^
#   head       ^
#   tail       ^

# Behaviors
#
# - Because array size is fixed, wrap around at the end
# - To push, move `cursor` and `head` forward together
	# When reaching `tail`, move `tail` forward, so it stays one step ahead
# - To undo, move only `cursor` backward, up to `tail`, inclusive
# - To redo, move only `cursor` forward, up to `head`, inclusive

function args_history_init {
	[[ -z $ARGS_HISTORY_MAX ]] && args_history_reset
}

function args_history_reset {
	ARGS_HISTORY=()
	ARGS_HISTORY_MAX=100
	ARGS_HISTORY_CURSOR=0
	ARGS_HISTORY_HEAD=0
	ARGS_HISTORY_TAIL=0
	ARGS_HISTORY_UNDO_EXCEEDED=0
	ARGS_HISTORY_REDO_EXCEEDED=0
}

function args_history_push {
	# Move `cursor` and `head` forward together
	ARGS_HISTORY_CURSOR=$(args_history_increment $ARGS_HISTORY_CURSOR)
	ARGS_HISTORY_HEAD=$ARGS_HISTORY_CURSOR
	ARGS_HISTORY[$ARGS_HISTORY_CURSOR]=$1

	# When reaching `tail`, move `tail` forward, so it stays one step ahead
	if [[ $ARGS_HISTORY_CURSOR -eq $ARGS_HISTORY_TAIL ]]; then
		ARGS_HISTORY_TAIL=$(args_history_increment $ARGS_HISTORY_TAIL)
	fi

	# Because array size is fixed, wrap around at the end
	[[ $ARGS_HISTORY_TAIL -eq 0 ]] && ARGS_HISTORY_TAIL=1
}

function args_history_replace_current {
	ARGS_HISTORY[$ARGS_HISTORY_CURSOR]=$1
}

function args_history_undo {
	# To undo, move only `cursor` backward, up to `tail`, inclusive
	local args_history_prev; args_history_prev=$(args_history_decrement "$ARGS_HISTORY_CURSOR")

	if [[ $ARGS_HISTORY_CURSOR -ne $ARGS_HISTORY_TAIL ]]; then
		ARGS_HISTORY_CURSOR=$args_history_prev
	else
		ARGS_HISTORY_UNDO_EXCEEDED=1
	fi
}

function args_history_undo_error_bar {
	# If we hit undo limit, show undo error bar once
	if [[ $ARGS_HISTORY_UNDO_EXCEEDED -eq 1 ]]; then
		ARGS_HISTORY_UNDO_EXCEEDED=0
		red_bar 'Reached the end of undo history'
	fi
}

function args_history_redo {
	# To redo, move only `cursor` forward, up to `head`, inclusive
	local args_history_next; args_history_next=$(args_history_increment "$ARGS_HISTORY_CURSOR")

	if [[ $ARGS_HISTORY_CURSOR -ne $ARGS_HISTORY_HEAD ]]; then
		ARGS_HISTORY_CURSOR=$args_history_next
	else
		ARGS_HISTORY_REDO_EXCEEDED=1
	fi
}

function args_history_redo_error_bar {
	# If we hit redo limit, show redo error bar once
	if [[ $ARGS_HISTORY_REDO_EXCEEDED -eq 1 ]]; then
		ARGS_HISTORY_REDO_EXCEEDED=0
		red_bar 'Reached the end of redo history'
	fi
}

function args_history_entries {
	echo "cursor: $ARGS_HISTORY_CURSOR"
	echo "head: $ARGS_HISTORY_HEAD"
	echo "tail: $ARGS_HISTORY_TAIL"
	echo "max: $ARGS_HISTORY_MAX"

	local index=$ARGS_HISTORY_HEAD

	# Print from head to tail, inclusive
	while true; do
		echo
		echo '----------------------------------------'
		echo "Index $index"
		echo '----------------------------------------'
		echo "${ARGS_HISTORY[index]}"

		[[ $index -eq $ARGS_HISTORY_TAIL ]] && break

		# Decrement index accounting for wrap-around and 1-based indexing
		index=$(((index - 2 + ARGS_HISTORY_MAX) % ARGS_HISTORY_MAX + 1))
	done
}

#
# Helpers
#

function args_history_increment {
	echo $(($1 % ARGS_HISTORY_MAX + 1))
}

function args_history_decrement {
	local args_history_decrement; args_history_decrement=$((ARGS_HISTORY_CURSOR - 1))
	[[ $args_history_decrement -eq 0 ]] && args_history_decrement=$ARGS_HISTORY_MAX
	echo $args_history_decrement
}
