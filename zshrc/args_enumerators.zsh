function all {
	local command=$*

	for number in $(seq 1 "$(args_size)"); do
		echo
		args_keymap_n "$number" "$command" &
	done

	wait
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
