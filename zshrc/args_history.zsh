#
# Args history (via a circular buffer)
#

# Visualize
#
#              123456789
#   index      ^
#   head       ^
#   tail       ^

# Behaviors
#
# - Because array size is fixed, wrap around at the end
# - To push, move `index` and `head` forward together
	# When reaching `tail`, move `tail` forward, so it stays one step ahead
# - To undo, move only `index` backward, up to `tail`, inclusive
# - To redo, move only `index` forward, up to `head`, inclusive

function args_history_init {
	[[ -z $ARGS_HISTORY_MAX ]] && args_history_reset
}

function args_history_reset {
	ARGS_HISTORY=()
	ARGS_HISTORY_MAX=100
	ARGS_HISTORY_INDEX=$ARGS_HISTORY_MAX # The first element will be at index 1
	ARGS_HISTORY_HEAD=$ARGS_HISTORY_INDEX
	ARGS_HISTORY_TAIL=-1
	ARGS_HISTORY_UNDO_EXCEEDED=0
	ARGS_HISTORY_REDO_EXCEEDED=0
}

function args_history_push {
	# Move `index` and `head` forward together
	ARGS_HISTORY_INDEX=$(args_history_increment $ARGS_HISTORY_INDEX)
	ARGS_HISTORY_HEAD=$ARGS_HISTORY_INDEX
	ARGS_HISTORY[$ARGS_HISTORY_INDEX]=$1

	# When reaching `tail`, move `tail` forward, so it stays one step ahead
	if [[ $ARGS_HISTORY_INDEX -eq $ARGS_HISTORY_TAIL ]]; then
		ARGS_HISTORY_TAIL=$(args_history_increment $ARGS_HISTORY_TAIL)
	fi

	# Because array size is fixed, wrap around at the end
	[[ $ARGS_HISTORY_TAIL -eq 0 ]] && ARGS_HISTORY_TAIL=1

	# If `tail` has not be set yet, set it to `index`
	[[ $ARGS_HISTORY_TAIL -eq -1 ]] && ARGS_HISTORY_TAIL=$ARGS_HISTORY_INDEX
}

function args_history_replace_current {
	ARGS_HISTORY[$ARGS_HISTORY_INDEX]=$1
}

function args_history_undo {
	# To undo, move only `index` backward, up to `tail`, inclusive
	local args_history_prev; args_history_prev=$(args_history_decrement "$ARGS_HISTORY_INDEX")

	if [[ $ARGS_HISTORY_INDEX -ne $ARGS_HISTORY_TAIL ]]; then
		ARGS_HISTORY_INDEX=$args_history_prev
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
	# To redo, move only `index` forward, up to `head`, inclusive
	local args_history_next; args_history_next=$(args_history_increment "$ARGS_HISTORY_INDEX")

	if [[ $ARGS_HISTORY_INDEX -ne $ARGS_HISTORY_HEAD ]]; then
		ARGS_HISTORY_INDEX=$args_history_next
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
	[[ $ARGS_HISTORY_TAIL -eq -1 ]] && echo '(empty)' && return

	echo "index: $ARGS_HISTORY_INDEX"
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

function args_history_set_index {
	local index=$1

	# Zsh array index is 1-based
	[[ $index -le 0 ]] && return 1

	local max=$ARGS_HISTORY_MAX
	local head=$ARGS_HISTORY_HEAD
	local tail=$ARGS_HISTORY_TAIL

	# Check if index is within range
	if 	[[
		# When there no wrap around
		$tail -le $index && $index -le $head ||
		# When there is wrap around at the end, and `index` is near `0`
		$tail -gt $head && $tail -gt $index && $((tail - max)) -le $index && $index -le $head ||
		# When there is wrap around at the end, and `index` is near `max`
		$tail -gt $head && $tail -le $index && $index -gt $head && $((index - max)) -le $head
	]]; then

		ARGS_HISTORY_INDEX=$index
		return 0
	else
		return 1
	fi
}

#
# Helpers
#

function args_history_increment {
	local index=$1
	echo $((index % ARGS_HISTORY_MAX + 1))
}

function args_history_decrement {
	local index=$1
	local args_history_decrement; args_history_decrement=$(($1 - 1))
	[[ $args_history_decrement -eq 0 ]] && args_history_decrement=$ARGS_HISTORY_MAX
	echo $args_history_decrement
}
