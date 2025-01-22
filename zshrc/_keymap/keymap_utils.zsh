#
# This file contains one-off functions not used by `keymap_init, keymap_invoke`
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
			keymap_print_entry '(zsh keymaps)' "$entry" "$max_command_size"
		done
	)

	echo
	echo "$output" | bw | strip_left | args_keymap_s "${filters[@]}"
}

function keymap_print_entries {
	local entries=("$@")

	local max_command_size; max_command_size=$(keymap_get_max_command_size "${entries[@]}")

	echo
	for entry in "${entries[@]}"; do
		keymap_print_entry '(zsh keymaps)' "$entry" "$max_command_size"
	done
}
