#
# Getters
#

# TODO refactor away some of these getters
# args_plain should be a | helper
# args_list and args_list_plain should go
function args_plain {
	local input=$1

	if [[ -z "$input" ]]; then
		args_history_current | bw | expand
	else
		echo "$input" | bw | expand
	fi
}

function args_list {
	args_history_current | nl
}

function args_list_plain {
	args_history_current | nl | bw | expand
}

function args_size {
	args_history_current | wc -l
}

function args_columns {
	local use_top_row=$1

	# Skip the `nl` column, then start accumulating `columns` starting with `current_column`
	local skip_nl_column=1
	local columns=''
	local current_column=a

	# Delimit columns using on the top row, or else use the bottom row
	if [[ ${use_top_row} -eq 1 ]]; then
		row=$(args_list_plain | head -1)
	else
		row=$(args_list_plain | tail -1)
	fi

	# Iterate over each character in the row
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

function args_select_column {
	local use_top_row=$1
	local selected_column=$2

	if [[ -z $selected_column ]]; then
		args_list
		args_columns_bar "$use_top_row"
	else
		local columns; columns=$(args_columns "$use_top_row")
		local first_column; first_column=$(index_of "$columns" a)
		local target_column; target_column=$(index_of "$columns" "$selected_column")
		local next_column; next_column=$(index_of "$columns" "$(next_ascii "$selected_column")")
		local column_start; column_start=$([[ "$target_column" -ne 0 ]] && echo "$target_column" || echo "$first_column")
		local column_end; column_end=$([[ "$next_column" -ne 0 ]] && echo $((next_column - 1)))

		# Select the specified column
		args_list_plain | cut -c "$column_start"-"$column_end" | strip_right | as

		# If selection was out of range and had no effect, show columns bar again for convenience
		if [[ $ARGS_PUSHED -eq 0 && $(index_of "$(args_columns "$use_top_row")" b) -ne 0 ]]; then
			args_columns_bar "$use_top_row"
		fi

		# Set global states to be used by `u`
		ARGS_USED_TOP_ROW=$use_top_row
	fi
}

#
# `|` Helpers
#

function args_save {
	# Get the piped input; if there is not any, abort
	local new_args; new_args=$(cat - | head -1000 | compact)
	[[ -z "$new_args" ]] && return

	# If specified, insert `#` after the first column to soft-select it
	local is_soft_select=$1; shift
	[[ $is_soft_select == "$ARGS_SOFT_SELECT" ]] && new_args=$(echo "$new_args" | insert_hash)

	# If there are filters, apply them
	local filters=("$@")
	if [[ -n "${filters[*]}" ]]; then
		new_args=$(echo "$new_args" | args_filter "${filters[@]}")
	fi

	# If the new args are different than the current args, push the new args
	if [[ $(args_plain "$new_args") != $(args_plain) ]]; then
		args_history_push "$new_args"

		# Set global states to be used by `n, nn, u`
		ARGS_PUSHED=1
		# shellcheck disable=SC2034
		ARGS_USED_TOP_ROW=

	# Otherwise, replace the current args because `grep` coloring could have changed
	else
		args_history_replace_current "$new_args"

		# Set global states to be used by `n, nn`
		ARGS_PUSHED=0
	fi

	args_list
}

function args_filter {
	local filters=("$@")

	# Expand each argument into a separate `grep` filter to allow matching out-of-order
	local greps="grep ${filters// / | grep }"

	# Treat any argument with a leading `-` as a negative match
	greps=${greps// -/ --invert-match }

	# Do not add coloring yet as coloring from a previous `grep` can mess up the next `grep`
	greps=${greps//grep/grep --color=never --ignore-case}

	# Now that filtering is done, add coloring for all positive matches
	local positive_filters=${${(j: :)filters:#-*}// /|}
	greps+=" | egrep --color=always --ignore-case '$positive_filters'"

	eval "$greps"
}
