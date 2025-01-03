### Args history
#
# Visualization of circular buffer
#
#              123456789
#   cursor     ^
#   head       ^
#   tail       ^
#
# - Array size is fixed, wrap around the end
# - To push, move `cursor` and `head` forward together
# - When reaching tail, keep `tail` always one step ahead
# - To undo, move only `cursor` backward, up to `tail`
# - To redo, move only `cursor` forward, up to `head`
function args-init { ARGS_HISTORY_MAX=100; ARGS_HISTORY=(); ARGS_CURSOR=0; ARGS_HEAD=0; ARGS_TAIL=0 }; [[ -z $ARGS_HISTORY_MAX ]] && args-init
function args-push { ARGS_CURSOR=$(args-increment $ARGS_CURSOR); ARGS_HISTORY[$ARGS_CURSOR]=$1; ARGS_HEAD=$ARGS_CURSOR; [[ $ARGS_CURSOR -eq $ARGS_TAIL ]] && ARGS_TAIL=$(args-increment $ARGS_TAIL); [[ $ARGS_TAIL -eq 0 ]] && ARGS_TAIL=1 }
function args-undo { ARGS_PREV=$(args-decrement $ARGS_CURSOR); [[ $ARGS_CURSOR -ne $ARGS_TAIL ]] && ARGS_CURSOR=$ARGS_PREV || ARGS_UNDO_EXCEEDED=1 }
function args-redo { ARGS_NEXT=$(args-increment $ARGS_CURSOR); [[ $ARGS_CURSOR -ne $ARGS_HEAD ]] && ARGS_CURSOR=$ARGS_NEXT || ARGS_REDO_EXCEEDED=1 }
function args-undo-bar { [[ $ARGS_UNDO_EXCEEDED -eq 1 ]] && { ARGS_UNDO_EXCEEDED=0; red-bg '  Reached the end of undo history  ' } }
function args-redo-bar { [[ $ARGS_REDO_EXCEEDED -eq 1 ]] && { ARGS_REDO_EXCEEDED=0; red-bg '  Reached the end of redo history  ' } }
function args-replace { ARGS_HISTORY[$ARGS_CURSOR]=$1 }
function args-increment { echo $(($1 % ARGS_HISTORY_MAX + 1)) }
function args-decrement { ARGS_DECREMENT=$(($ARGS_CURSOR - 1)); [[ $ARGS_DECREMENT -eq 0 ]] && ARGS_DECREMENT=$ARGS_HISTORY_MAX; echo $ARGS_DECREMENT }
function args-history {
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
		echo ${ARGS_HISTORY[index]}

		[[ $index -eq $ARGS_TAIL ]] && break

		# Decrement index accounting for wrap-around and 1-based indexing
		index=$(((index - 2 + $ARGS_HISTORY_MAX) % $ARGS_HISTORY_MAX + 1))
	done
}
