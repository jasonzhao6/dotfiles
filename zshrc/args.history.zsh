#
# Args history
#

# Visualization of circular buffer:
#
#              123456789
#   cursor     ^
#   head       ^
#   tail       ^

# Behavior of circular buffer:
#
# - Array size is fixed, wrap around the end
# - To push, move `cursor` and `head` forward together
# - When reaching tail, keep `tail` always one step ahead
# - To undo, move only `cursor` backward, up to `tail`, inclusive
# - To redo, move only `cursor` forward, up to `head`, inclusive

function args_init {
	[[ -z $ARGS_HISTORY_MAX ]] && args_reset
}

function args_reset {
	ARGS_HISTORY_MAX=100
	ARGS_HISTORY=()
	ARGS_CURSOR=0
	ARGS_HEAD=0
	ARGS_TAIL=0
	ARGS_UNDO_EXCEEDED=0
	ARGS_REDO_EXCEEDED=0
}

function args_push {
	# Move `cursor` and `head` forward together
	ARGS_CURSOR=$(args_increment $ARGS_CURSOR)
	ARGS_HEAD=$ARGS_CURSOR
	ARGS_HISTORY[$ARGS_CURSOR]=$1

	# When reaching tail, keep `tail` always one step ahead
	[[ $ARGS_CURSOR -eq $ARGS_TAIL ]] && ARGS_TAIL=$(args_increment $ARGS_TAIL)

	# Array size is fixed, wrap around the end
	[[ $ARGS_TAIL -eq 0 ]] && ARGS_TAIL=1
}

function args_undo {
	# To undo, move only `cursor` backward, up to `tail`, inclusive
	local args_prev; args_prev=$(args_decrement "$ARGS_CURSOR")
	[[ $ARGS_CURSOR -ne $ARGS_TAIL ]] && ARGS_CURSOR=$args_prev || ARGS_UNDO_EXCEEDED=1
}

function args_redo {
	# To redo, move only `cursor` forward, up to `head`, inclusive
	local args_next; args_next=$(args_increment "$ARGS_CURSOR")
	[[ $ARGS_CURSOR -ne $ARGS_HEAD ]] && ARGS_CURSOR=$args_next || ARGS_REDO_EXCEEDED=1
}

function args_undo_bar {
	[[ $ARGS_UNDO_EXCEEDED -ne 1 ]] && return

	ARGS_UNDO_EXCEEDED=0
	red_bg '  Reached the end of undo history  '
}

function args_redo_bar {
	[[ $ARGS_REDO_EXCEEDED -ne 1 ]] && return

	ARGS_REDO_EXCEEDED=0
	red_bg '  Reached the end of redo history  '
}

function args_replace {
	ARGS_HISTORY[$ARGS_CURSOR]=$1
}

function args_history {
	echo "cursor: $ARGS_CURSOR"
	echo "head: $ARGS_HEAD"
	echo "tail: $ARGS_TAIL"
	echo "max: $ARGS_HISTORY_MAX"

	local index=$ARGS_HEAD

	# Print from head to tail, inclusive
	while true; do
		echo
		echo '----------------------------------------'
		echo "Index $index"
		echo '----------------------------------------'
		echo "${ARGS_HISTORY[index]}"

		[[ $index -eq $ARGS_TAIL ]] && break

		# Decrement index accounting for wrap-around and 1-based indexing
		index=$(((index - 2 + ARGS_HISTORY_MAX) % ARGS_HISTORY_MAX + 1))
	done
}

#
# Helpers
#

function args_increment {
	echo $(($1 % ARGS_HISTORY_MAX + 1))
}

function args_decrement {
	local args_decrement; args_decrement=$((ARGS_CURSOR - 1))
	[[ $args_decrement -eq 0 ]] && args_decrement=$ARGS_HISTORY_MAX
	echo $args_decrement
}
