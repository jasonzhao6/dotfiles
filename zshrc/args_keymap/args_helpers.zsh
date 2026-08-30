#
# Getters
#

function args_helpers_plain {
	local input=$1

	if [[ -z "$input" ]]; then
		args_history_current | bw | expand
	else
		echo "$input" | bw | expand
	fi
}

function args_helpers_list {
	local content; content=$(args_history_current)
	[[ -z $content ]] && return

	echo

	# Strip any trailing whitespace added by `nl`
	echo "$content" | nl | strip_right
}

function args_helpers_list_plain {
	args_history_current | nl | bw | expand
}

function args_helpers_size {
	args_history_current | wc -l
}

function args_helpers_columns {
	# Skip the `nl` column, then start accumulating `columns` starting with `current_column`
	local skip_nl_column=1
	local columns=''
	local current_column=a

	# Delimit columns using the bottom row
	local row; row=$(args_helpers_list_plain | tail -1)

	# Iterate over each character in the row
	local i
	for i in $(seq 1 ${#row}); do
		# A new column starts when transitioning from a space to a non-space character
		if [[ ${row[$i-1]} == ' ' && ${row[$i]} != ' ' ]]; then
			# Skip the `nl` column
			if [[ $skip_nl_column -eq 1 ]]; then
				skip_nl_column=0
				columns+=' '
			else
				columns+=$current_column
				current_column=$(next_ascii "$current_column")
			fi
		else
			columns+=' '
		fi
	done

	echo "$columns"
}

function args_helpers_columns_bar {
	green_bg "$(args_helpers_columns)"
}

# `columns` is the bar under the list: each letter sits at its column's start char
# `index_of` turns a letter back into that position, or 0 when the letter is absent
# So a column runs from its own letter to just before the next, open at the last
function args_helpers_column_range {
	local selected_column=$1

	local columns; columns=$(args_helpers_columns)
	local first_column; first_column=$(index_of "$columns" a)
	local target_column; target_column=$(index_of "$columns" "$selected_column")
	local next_column; next_column=$(index_of "$columns" "$(next_ascii "$selected_column")")

	local column_start; column_start=$([[ "$target_column" -ne 0 ]] && echo "$target_column" || echo "$first_column")
	local column_end; column_end=$([[ "$next_column" -ne 0 ]] && echo $((next_column - 1)))

	echo "${column_start}-${column_end}"
}

# Slice one column out of every row. Boundaries come from the bottom row, so a row
# holding a wider value starts left of them (`ls -l` right-aligns sizes) or runs
# past them; when the slice cuts a token, take the rest of that token too
function args_helpers_column_slice {
	local selected_column=$1

	local range; range=$(args_helpers_column_range "$selected_column")

	args_helpers_list_plain | awk -v lo="${range%-*}" -v hi="${range#*-}" '
		{
			last = length($0)

			# A row too short to reach the column has no value in it; without this,
			# widening walks back over the off-the-end gap and grabs the last token
			if (lo > last) { print ""; next }

			end = (hi == "" || hi > last) ? last : hi

			# Widen only when a token straddles the edge, so a blank column stays blank
			start = lo
			while (start > 1 && substr($0, start, 1) != " " && substr($0, start - 1, 1) != " ") start--
			while (end < last && substr($0, end, 1) != " " && substr($0, end + 1, 1) != " ") end++

			print substr($0, start, end - start + 1)
		}
	'
}

#
# `|` Helpers
#

function args_helpers_save {
	# Get the piped input; if there is not any, abort
	local new_args; new_args=$(head -10000 | compact)
	[[ -z "$new_args" ]] && return

	# If specified, insert `#` after the first column to soft-select it
	local is_soft_select=$1; shift
	[[ $is_soft_select == "$ARGS_SOFT_SELECT" ]] && new_args=$(echo "$new_args" | insert_hash)

	# If there are filters, apply them
	local filters=("$@")
	if [[ -n "${filters[*]}" ]]; then
		new_args=$(echo "$new_args" | args_helpers_filter "${filters[@]}")
	fi

	# If the new args are different than the current args, push the new args
	if [[ $(args_helpers_plain "$new_args") != "$(args_helpers_plain)" ]]; then
		args_history_push "$new_args"

	# Otherwise, replace the current args because `grep` coloring could have changed
	else
		args_history_replace_current "$new_args"
	fi

	args_helpers_list
}

function args_helpers_filter {
	local filters=("$@")

	# Expand each argument into a separate `grep` filter to allow matching out-of-order
	local greps="grep ${filters// / | grep }"

	# Treat any argument with a leading `-` as a negative match
	greps=${greps// -/ --invert-match }

	# Do not add coloring yet as coloring from a previous `grep` can mess up the next `grep`
	greps=${greps//grep/grep --color=never --ignore-case}

	# Now that filtering is done, add coloring for all positive matches
	local positive_filters=${${(j: :)filters:#-*}// /|}
	greps+=" | grepE --color=always --ignore-case '$positive_filters'"

	eval "$greps"
}
