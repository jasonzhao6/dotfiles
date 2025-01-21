ARGS_NAMESPACE='args_keymap'
ARGS_ALIAS='a'
ARGS_DOT="${ARGS_ALIAS}${KEYMAP_DOT}"

ARGS_KEYMAP=(
	"${ARGS_DOT}s # Save as args"
	"${ARGS_DOT}s <match>* <-mismatch>* # Save as args & filter"
	"${ARGS_DOT}so # Save as args & soft-select the 1st column"
	"${ARGS_DOT}so <match>* <-mismatch>* # Save as args & soft-select the 1st column & filter"
	''
	'<1-100> <command> # Use an arg'
	'0 <command> # Use the last arg'
	"each <command> # Use each arg in series"
	"all <command> # Use all args in parallel"
	"map <command> # Map args, e.g \`${ARGS_ALIAS}m echo '\$((~~ * 10))'\`"
	''
	"${ARGS_DOT}o <command> # Use a random arg"
	"${ARGS_DOT}n <number> <command> # Use an arg by number"
	"${ARGS_DOT}e <start> <finish> <command> # Use args within a sequence"
	''
	"${ARGS_DOT}a # List args"
	"${ARGS_DOT}a <match>* <-mismatch>* # Filter args"
	"${ARGS_DOT}d # Dedupe args"
	"${ARGS_DOT}t # Tabulate columns"
	"${ARGS_DOT}w # Delimit columns based on the top row"
	"${ARGS_DOT}w <letter> # Select a column based on the top row"
	"${ARGS_DOT}v # Delimit columns based on the bottom row"
	"${ARGS_DOT}v <letter> # Select a column based on the bottom row"
	"${ARGS_DOT}z # Select the last column based on the bottom row"
	''
	"${ARGS_DOT}u # Undo \"Filter args\" or \"Select a column\""
	"${ARGS_DOT}r # Redo \"Filter args\" or \"Select a column\""
	"${ARGS_DOT}h # List history entries"
	"${ARGS_DOT}h <index> # Select an entry by index"
	"${ARGS_DOT}hc # Clear history entries"
	''
	"${ARGS_DOT}c # Copy args"
	"${ARGS_DOT}c <number> # Copy an arg by number"
	"${ARGS_DOT}y # Yank args"
	"${ARGS_DOT}p # Put args (in a different tab)"
)

keymap_init $ARGS_NAMESPACE $ARGS_ALIAS "${ARGS_KEYMAP[@]}"

function args_keymap {
	# When invoked as standalone command
	if [[ -t 0 ]]; then
		# If the first arg is not a `key`, filter args
		if ! keymap_is_key_mapped "$ARGS_ALIAS" "$1" "${ARGS_KEYMAP[@]}"; then
			args_keymap_a "$@"
			return
		fi

	# When invoked after a pipe `|`, save args
	else
		args_save "$is_soft_select" "$@"
		return
	fi

	keymap_invoke $ARGS_NAMESPACE $ARGS_ALIAS ${#ARGS_KEYMAP} "${ARGS_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

# Constants
ARGS_SOFT_SELECT='Soft-select the 1st column by inserting a `#` before the 2nd column'
ARGS_YANK_FILE="$HOME/.zshrc.args"

# States
# shellcheck disable=SC2034
ARGS_PUSHED=
ARGS_USED_TOP_ROW=

source "$ZSHRC_DIR/$ARGS_NAMESPACE/args_enumerators.zsh"
source "$ZSHRC_DIR/$ARGS_NAMESPACE/args_helpers.zsh"
source "$ZSHRC_DIR/$ARGS_NAMESPACE/args_history.zsh"; args_history_init
source "$ZSHRC_DIR/$ARGS_NAMESPACE/args_numbers.zsh"

# shellcheck disable=SC2120
function args_keymap_a {
	local filters=("$@")

	# If there is no `filters`, list args
	if [[ -z "${filters[*]}" ]]; then
		args_list

	# Otherwise, apply `filters`, then list args
	else
		args_plain | args_filter "${filters[@]}" | args_keymap_s
	fi
}

function args_keymap_c {
	local string=$*

	if [[ -z $string ]]; then
		args_plain | pbcopy
	else
		echo -n "$string" | pbcopy
	fi
}

function args_keymap_d {
	args_history_current | uniq | args_keymap_s
}
function args_keymap_e {
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
		echo
		red_bar "Index out of range: $index"
	fi
}

function args_keymap_hc {
	args_history_reset
}

function args_keymap_n {
	local number=$1; shift
	local command=$*

	if [[ -n $number && -n $command ]]; then
		local arg; arg="$(args_plain | sed -n "${number}p" | sed 's/ *#.*//' | strip)"

		if [[ $command != *'~~'* ]]; then
			echo_eval "$command $arg"
		else
			echo_eval "${command//~~/$arg}"
		fi
	fi
}

function args_keymap_o {
	local command=$*

	args_keymap_n $((RANDOM % $(args_size) + 1)) "$command"
}

function args_keymap_p {
	echo "$(<"$ARGS_YANK_FILE")" | args_keymap_s
}

function args_keymap_r {
	args_history_redo
	args_list
	args_history_redo_error_bar
}

# shellcheck disable=SC2120
function args_keymap_s {
	# Users see the interface of this mapping as `s <match>* <-mismatch>*`
	# Only `so` know this interface as `s <is_soft_select> <match>* <-mismatch>*`
	local is_soft_select=$1
	[[ $is_soft_select == "$ARGS_SOFT_SELECT" ]] && shift || is_soft_select=0

	local filters=("$@")

	# When invoked as standalone command
	if [[ -t 0 ]]; then
		eval "$(prev_command)" | args_save "$is_soft_select" "${filters[@]}"

	# When invoked after a pipe `|`
	else
		args_save "$is_soft_select" "${filters[@]}"
	fi
}

function args_keymap_so {
	local filters=("$@")

	as "$ARGS_SOFT_SELECT" "${filters[@]}"
}

function args_keymap_t {
	args_history_current | column -t | args_keymap_s
}

function args_keymap_u {
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

function args_keymap_v {
	local index=$1

	args_select_column 0 "$index"
}

function args_keymap_w {
	local index=$1

	args_select_column 1 "$index"
}

function args_keymap_y {
	args_history_current > "$ARGS_YANK_FILE"
}

function args_keymap_z {
	local columns; columns=$(args_columns 0 | strip_right)
	local last_column=${columns: -1}

	args_select_column 0 "$last_column"
}
