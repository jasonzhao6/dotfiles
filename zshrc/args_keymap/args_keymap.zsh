ARGS_NAMESPACE='args_keymap'
ARGS_ALIAS='a'
ARGS_DOT="${ARGS_ALIAS}${KEYMAP_DOT}"

ARGS_KEYMAP=(
	"${ARGS_DOT}a <match>* <-mismatch>* # List args & filter"
	"${ARGS_DOT}s <match>* <-mismatch>* ${KEYMAP_PIPE_PATTERN} # Save as args & filter"
	"${ARGS_DOT}so <match>* <-mismatch>* ${KEYMAP_PIPE_PATTERN} # Save & filter & soft-select 1st column"
	''
	"${ARGS_DOT}o <command> # Use first arg"
	"${ARGS_DOT}e <command> # Use last arg"
	'(1-100) <command> # Use an arg by number, up to 100'
	"${ARGS_DOT}n <number> <command> # Use an arg by number, beyond 100"
	'0 <command> # Use last arg'
	''
	"map <command> # Map args, e.g \`map echo '\$((~~ * 10))'\`"
	"each <command> # Use each arg in foreground"
	"all <command> # Use all args in background"
	"${ARGS_DOT}f <start> <finish> <command> # Use selected args in foreground"
	"${ARGS_DOT}b <start> <finish> <command> # Use selected args in background"
	''
	"${ARGS_DOT}i # Delimit columns by letters"
	"${ARGS_DOT}i <letter> # Select a column"
	"${ARGS_DOT}ii <letter> # Sort by a column"
	''
	"${ARGS_DOT}t # Tabulate columns"
	"${ARGS_DOT}r # Reverse args"
	"${ARGS_DOT}d # Dedupe args"
	''
	"${ARGS_DOT}u # Go back to prev list of args"
	"${ARGS_DOT}uu # Go forward to next list of args"
	"${ARGS_DOT}h # List history entries"
	"${ARGS_DOT}h <history index> # Select an entry by index"
	"${ARGS_DOT}hc # Clear history entries"
	''
	"${ARGS_DOT}y # Yank args to file (in one tab)"
	"${ARGS_DOT}p # Put args from file (in another tab)"
	"${ARGS_DOT}c <arg>? # Copy an arg (Default: All) to pasteboard"
)

keymap_init $ARGS_NAMESPACE $ARGS_ALIAS "${ARGS_KEYMAP[@]}"

function args_keymap {
	keymap_show $ARGS_NAMESPACE $ARGS_ALIAS ${#ARGS_KEYMAP} "${ARGS_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

# Sources
source "$ZSHRC_SRC_DIR/$ARGS_NAMESPACE/args_enumerators.zsh"
source "$ZSHRC_SRC_DIR/$ARGS_NAMESPACE/args_helpers.zsh"
source "$ZSHRC_SRC_DIR/$ARGS_NAMESPACE/args_history.zsh"; args_history_init
source "$ZSHRC_SRC_DIR/$ARGS_NAMESPACE/args_numbers.zsh"

# Constants
ARGS_BACKGROUND_OUTPUTS_FILE="$ZSHRC_DATA_DIR/args.background-outputs.txt"
ARGS_SOFT_SELECT='Soft-select the 1st column by inserting a `#` before the 2nd column'
ARGS_YANK_FILE="$ZSHRC_DATA_DIR/args.yank.txt"

# States
# shellcheck disable=SC2034


# shellcheck disable=SC2120
function args_keymap_a {
	local filters=("$@")

	# If there is no `filters`, list args
	if [[ -z "${filters[*]}" ]]; then
		args_helpers_list

	# Otherwise, apply `filters`, then list args
	else
		args_helpers_plain | args_helpers_filter "${filters[@]}" | args_keymap_s
	fi
}

function args_keymap_b {
	local start=$1; shift
	local finish=$1; shift # `end` is a reserved keyword
	local command=$*

	rm -f "$ARGS_BACKGROUND_OUTPUTS_FILE"

	# Collect arg outputs in `ARGS_BACKGROUND_OUTPUTS_FILE` to print at the end
	# Otherwise, arg outputs are interleaved with `&` outputs
	for number in $(seq "$start" "$finish"); do
		echo
		args_keymap_n "$number" "$command" >> "$ARGS_BACKGROUND_OUTPUTS_FILE" &
	done

	wait

	echo
	cat "$ARGS_BACKGROUND_OUTPUTS_FILE"
}

function args_keymap_c {
	local string=$*

	if [[ -z $string ]]; then
		args_helpers_plain | pbcopy
	else
		echo -n "$string" | pbcopy
	fi
}

function args_keymap_d {
	args_history_current | sort --unique | args_keymap_s
}

function args_keymap_e {
	local command=$*

	args_keymap_n '$' "$command"
}

function args_keymap_f {
	local start=$1; shift
	local finish=$1; shift # `end` is a reserved keyword
	local command=$*

	for number in $(seq "$start" "$finish"); do
		echo
		args_keymap_n "$number" "$command"
	done
}

function args_keymap_h {
	local index=$1

	# If `index` is not specified, list history entries
	[[ -z $index ]] && args_history_entries && return

	# If `index` was set successfully, then list args at `index`
	if args_history_set_index "$index"; then
		args_keymap_a

	# Otherwise, list history entries again and show error bar
	else
		args_history_entries
		red_bar "Index out of range: $index"
	fi
}

function args_keymap_hc {
	args_history_reset
}

function args_keymap_i {
	local selected_column=$1

	# If no column specified, show columns bar
	if [[ -z $selected_column ]]; then
		args_helpers_list
		args_helpers_columns_bar
		return
	fi

	# Report when letter is out of range
	if [[ $(index_of "$(args_helpers_columns)" "$selected_column") -eq 0 ]]; then
		red_bar "Column '$selected_column' is out of range"
		return
	fi

	# Select the specified column
	args_helpers_column_slice "$selected_column" | strip_right | args_keymap_s
}

function args_keymap_ii {
	local selected_column=$1

	# If no column specified, show columns bar
	if [[ -z $selected_column ]]; then
		args_helpers_list
		args_helpers_columns_bar
		return
	fi

	# Report when letter is out of range
	if [[ $(index_of "$(args_helpers_columns)" "$selected_column") -eq 0 ]]; then
		red_bar "Column '$selected_column' is out of range"
		return
	fi

	# `paste` prepends the column as a tab-separated sort key
	# `sort` orders by that key alone
	# `cut` drops it again, leaving the rows untouched
	paste \
		<(args_helpers_column_slice "$selected_column" | strip) \
		<(args_history_current) |
		sort --field-separator=$'\t' --key=1,1 --version-sort --stable |
		cut -f2- |
		args_keymap_s
}

function args_keymap_n {
	local number=$1; shift
	local command=$*

	if [[ -n $number && -n $command ]]; then
		# For file commands (`n`, `cat`) in a fresh shell with no args yet, act
		# on the cwd listing, as if `nn` had just run
		local first_word=${command%% *}
		if [[ $first_word == 'n' || $first_word == 'cat' ]]; then
			nav_helpers_populate_args_when_empty
		fi

		local arg; arg="$(args_helpers_plain | sed -n "${number}p" | sed 's/ *#.*//' | strip)"

		if [[ -e $arg ]]; then
			echo_eval "$command \"$arg\""
		elif [[ $command != *'~~'* ]]; then
			echo_eval "$command $arg"
		else
			echo_eval "${command//~~/$arg}"
		fi
	fi
}

function args_keymap_o {
	args_keymap_n 1 "$@"
}

function args_keymap_p {
	echo "$(<"$ARGS_YANK_FILE")" | args_keymap_s
}

function args_keymap_r {
	args_history_current | tail -r | args_keymap_s
}

# shellcheck disable=SC2120
function args_keymap_s {
	# Users see the interface of this mapping as `s {match}* {-mismatch}*`
	# Only `so` knows that the actual interface is `s {is_soft_select} {match}* {-mismatch}*`
	local is_soft_select=$1
	[[ $is_soft_select == "$ARGS_SOFT_SELECT" ]] && shift || is_soft_select=0

	local filters=("$@")

	# When invoked as standalone command
	if [[ -t 0 ]]; then
		eval "$(prev_command)" | args_helpers_save "$is_soft_select" "${filters[@]}"

	# When invoked after a pipe `|`
	else
		args_helpers_save "$is_soft_select" "${filters[@]}"
	fi
}

function args_keymap_so {
	local filters=("$@")

	args_keymap_s "$ARGS_SOFT_SELECT" "${filters[@]}"
}

function args_keymap_t {
	args_history_current | column -t | args_keymap_s
}

function args_keymap_u {
	args_history_undo
	args_helpers_list
	args_history_undo_error_bar
}

function args_keymap_uu {
	args_history_redo
	args_helpers_list
	args_history_redo_error_bar
}

function args_keymap_y {
	args_history_current > "$ARGS_YANK_FILE"
}
