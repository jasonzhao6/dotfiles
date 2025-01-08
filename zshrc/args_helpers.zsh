#
# Helpers
#

#
# Helpers after `|`
#

function args_save {
	local new_args; new_args=$(cat - | head -1000 | compact)

	# TODO move inside if, move up replace, use plain func, support filter
	# Insert '#' after the first column to soft-select it
	[[ -n $1 ]] && new_args=$(echo "$new_args" | insert_hash)

	if [[ -n "$new_args" ]]; then
		local new_args_plain; new_args_plain=$(echo "$new_args" | bw | expand)

		if [[ "$new_args_plain" != $(args_plain) ]]; then
			args_history_push "$ARGS"

			# Set global states used by `n, nn, u`
			ARGS_PUSHED=1
			ARGS_USED_TOP_ROW=
		else
			# Set global states used by `n, nn`
			ARGS_PUSHED=0
		fi

		# Always replace the args; sometimes content is the same, but grep coloring is different
		args_history_replace_current "$new_args"
		args_list
	fi
}
