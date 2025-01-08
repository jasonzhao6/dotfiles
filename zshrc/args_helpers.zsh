#
# Helpers
#

#
# `|` Helpers
#

# TODO support filter
function args_save {
	# Get the piped input; there is not any, abort
	local new_args; new_args=$(cat - | head -1000 | compact)
	[[ -z "$new_args" ]] && return

	# If requested, insert `#` after the first column to soft-select it
	local is_soft_select=$1
	[[ -n $is_soft_select ]] && new_args=$(echo "$new_args" | insert_hash)

	# If the new args are different than the current args, push the new args
	if [[ $(args_plain "$new_args") != $(args_plain) ]]; then
		args_history_push "$new_args"

		# Set global states used by `n, nn, u`
		ARGS_PUSHED=1
		ARGS_USED_TOP_ROW=

	# Otherwise, replace the current args anyway in case `grep` coloring has changed
	else
		args_history_replace_current "$new_args"

		# Set global states used by `n, nn`
		ARGS_PUSHED=0
	fi

	args_list
}






#
# Getters
#

function args { echo "${ARGS_HISTORY[$ARGS_HISTORY_INDEX]}"; }
function args_plain { [[ -z "$1" ]] && args | bw | expand || echo "$@" | bw | expand; }
function args_list { args | nl; }
function args_list_plain { args | nl | bw | expand; }
function args_list_size { args | wc -l; }
function args_coloring { echo "egrep --color=always --ignore-case '${${@:#-*}// /|}'"; }

function args_filtering {
	local filters

	# Expand each argument into a separate `grep` filter to allow matching out-of-order
	filters="grep ${*// / | grep }"

	# Treat any argument with a leading `-` as a negative match
	filters=${filters// -/ --invert-match }

	# Do not add coloring yet as coloring from a previous `grep` can mess up the next `grep`
	# `args_coloring` will add coloring for all positive matches immediately after `args_filtering`
	filters=${filters//grep/grep --color=never --ignore-case}

	echo "$filters"
}

function args_columns {
	# Whether to delimit based on the top row vs the bottom row
	local use_top_row=$1

	# Skip the `nl` column, then start accumulating `columns` starting with `current_column`
	local skip_nl_column=1
	local current_column=a
	local columns=''

	if [[ ${use_top_row} -eq 1 ]]; then
		row=$(args_list_plain | head -1)
	else
		row=$(args_list_plain | tail -1)
	fi

	for i in $(seq 1 ${#row}); do
		# A new column starts when transitioning from a space to a non-space character
		if [[ ${row[$i-1]} == ' ' && ${row[$i]} != ' ' ]]; then
			# Skip the `nl` column
			if [[ $skip_nl_column -eq 1 ]]; then
				skip_nl_column=0
				columns+=' '
			else
				columns+=$current_column
				current_column=$(next_ascii $current_column)
			fi
		else
			columns+=' '
		fi
	done

	echo "$columns"
}

function args_columns_bar {
	local use_top_row=$1

	green_bg "$(args_columns "$use_top_row")"
}

#
# Setters
#

function args_use_selection {
	if [[ -n $1 && -n $2 ]]; then
		local row; row="$(args_plain | sed -n "$1p" | sed 's/ *#.*//' | strip)"

		if [[ $(index_of "${(j: :)@}" '~~') -eq 0 ]]; then
			echo_eval "${*:2} $row"
		else
			echo_eval ${${*:2}//~~/$row}
		fi
	fi
}

function args_select_column {
	local use_top_row=$1
	local selected_column=$2

	if [[ -z $2 ]]; then
		args_list
		args_columns_bar "$use_top_row"
	else
		local columns; columns=$(args_columns "$use_top_row")
		local first_column; first_column=$(index_of "$columns" a)
		local target_column; target_column=$(index_of "$columns" "$selected_column")
		local next_column; next_column=$(index_of "$columns" "$(next_ascii "$selected_column")")
		local column_start; column_start=$([[ "$target_column" -ne 0 ]] && echo "$target_column" || echo "$first_column")
		local column_end; column_end=$([[ "$next_column" -ne 0 ]] && echo $((next_column - 1)))

		args_list_plain | cut -c "$column_start"-"$column_end" | strip_right | as

		# If a column was not selected, show columns bar again for convenience
		if [[ $ARGS_PUSHED -eq 0 && $(index_of "$(args_columns "$use_top_row")" b) -ne 0 ]]; then
			args_columns_bar "$use_top_row"
		fi

		# Set global states used by `u`
		ARGS_USED_TOP_ROW=$use_top_row
	fi
}

#
# Getters
#

function args { echo "${ARGS_HISTORY[$ARGS_HISTORY_INDEX]}"; }
function args_plain { [[ -z "$1" ]] && args | bw | expand || echo "$@" | bw | expand; }
function args_list { args | nl; }
function args_list_plain { args | nl | bw | expand; }
function args_list_size { args | wc -l; }
function args_coloring { echo "egrep --color=always --ignore-case '${${@:#-*}// /|}'"; }

function args_filtering {
	local filters

	# Expand each argument into a separate `grep` filter to allow matching out-of-order
	filters="grep ${*// / | grep }"

	# Treat any argument with a leading `-` as a negative match
	filters=${filters// -/ --invert-match }

	# Do not add coloring yet as coloring from a previous `grep` can mess up the next `grep`
	# `args_coloring` will add coloring for all positive matches immediately after `args_filtering`
	filters=${filters//grep/grep --color=never --ignore-case}

	echo "$filters"
}

function args_columns {
	# Whether to delimit based on the top row vs the bottom row
	local use_top_row=$1

	# Skip the `nl` column, then start accumulating `columns` starting with `current_column`
	local skip_nl_column=1
	local current_column=a
	local columns=''

	if [[ ${use_top_row} -eq 1 ]]; then
		row=$(args_list_plain | head -1)
	else
		row=$(args_list_plain | tail -1)
	fi

	for i in $(seq 1 ${#row}); do
		# A new column starts when transitioning from a space to a non-space character
		if [[ ${row[$i-1]} == ' ' && ${row[$i]} != ' ' ]]; then
			# Skip the `nl` column
			if [[ $skip_nl_column -eq 1 ]]; then
				skip_nl_column=0
				columns+=' '
			else
				columns+=$current_column
				current_column=$(next_ascii $current_column)
			fi
		else
			columns+=' '
		fi
	done

	echo "$columns"
}

function args_columns_bar {
	local use_top_row=$1

	green_bg "$(args_columns "$use_top_row")"
}

#
# Setters
#

function args_use_selection {
	if [[ -n $1 && -n $2 ]]; then
		local row; row="$(args_plain | sed -n "$1p" | sed 's/ *#.*//' | strip)"

		if [[ $(index_of "${(j: :)@}" '~~') -eq 0 ]]; then
			echo_eval "${*:2} $row"
		else
			echo_eval ${${*:2}//~~/$row}
		fi
	fi
}

function args_select_column {
	local use_top_row=$1
	local selected_column=$2

	if [[ -z $2 ]]; then
		args_list
		args_columns_bar "$use_top_row"
	else
		local columns; columns=$(args_columns "$use_top_row")
		local first_column; first_column=$(index_of "$columns" a)
		local target_column; target_column=$(index_of "$columns" "$selected_column")
		local next_column; next_column=$(index_of "$columns" "$(next_ascii "$selected_column")")
		local column_start; column_start=$([[ "$target_column" -ne 0 ]] && echo "$target_column" || echo "$first_column")
		local column_end; column_end=$([[ "$next_column" -ne 0 ]] && echo $((next_column - 1)))

		args_list_plain | cut -c "$column_start"-"$column_end" | strip_right | as

		# If a column was not selected, show columns bar again for convenience
		if [[ $ARGS_PUSHED -eq 0 && $(index_of "$(args_columns "$use_top_row")" b) -ne 0 ]]; then
			args_columns_bar "$use_top_row"
		fi

		# Set global states used by `u`
		# shellcheck disable=SC2034
		ARGS_USED_TOP_ROW=$use_top_row
	fi
}
