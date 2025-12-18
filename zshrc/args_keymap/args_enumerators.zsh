ALL_OUTPUT_FILE="$ZSHRC_DATA_DIR/args.all-output.txt"

function all {
	local command=$*

	rm -f "$ALL_OUTPUT_FILE"

	# Collect arg outputs in `ALL_OUTPUT_FILE` to print at the end
	# Otherwise, arg outputs are interleaved with `&` outputs
	for number in $(seq 1 "$(args_size)"); do
		args_keymap_n "$number" "$command" >> "$ALL_OUTPUT_FILE" &
	done

	wait

	echo
	cat "$ALL_OUTPUT_FILE"
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
