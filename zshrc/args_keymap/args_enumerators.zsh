function all {
	local command=$*

	rm -f "$ARGS_BACKGROUND_OUTPUTS_FILE"

	# Collect arg outputs in `ARGS_BACKGROUND_OUTPUTS_FILE` to print at the end
	# Otherwise, arg outputs are interleaved with `&` outputs
	for number in $(seq 1 "$(args_size)"); do
		args_keymap_n "$number" "$command" >> "$ARGS_BACKGROUND_OUTPUTS_FILE" &
	done

	wait

	echo
	cat "$ARGS_BACKGROUND_OUTPUTS_FILE"
}

function each {
	local command=$*

	for number in $(seq 1 "$(args_size)"); do
		echo
		args_keymap_n "$number" "$command"
	done
}

function map {
	local command=$*

	local map=''
	local arg

	for number in $(seq 1 "$(args_size)"); do
		echo
		arg=$(args_keymap_n "$number" "$command")
		map+="$arg\n"
		echo "$arg"
	done

	echo
	echo "$map" | args_keymap_s
}
