#
# One-off functions used outside fo `keymap_bash.zsh`
#

function keymap_files {
	find "$ZSHRC_DIR" -name '*_keymap.zsh' | grep --invert-match test | sort
}

function keymap_filter_entries {
	local namespace=$1; shift
	local filters=("$@")

	local entries=("${(P)$(echo "$namespace" | upcase)[@]}")
	local max_command_size; max_command_size=$(keymap_get_max_command_size "${entries[@]}")

	local output; output=$(
		for entry in "${entries[@]}"; do
			keymap_print_entry "$entry" "$max_command_size"
		done
	)

	echo
	echo "$output" | bw | args_keymap_s "${filters[@]}"
}

function keymap_print_entries {
	local entries=("$@")

	local max_command_size; max_command_size=$(keymap_get_max_command_size "${entries[@]}")

	echo
	for entry in "${entries[@]}"; do
		keymap_print_entry "$entry" "$max_command_size"
	done
}
