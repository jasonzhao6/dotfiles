#
# One-off functions used outside fo `keymap_bash.zsh`
#

function keymap_files {
	find "$ZSHRC_DIR" -name '*_keymap.zsh' | grep --invert-match test | sort
}

function keymap_print_entries {
	local entries=("$@")

	local max_command_size; max_command_size=$(keymap_get_max_command_size "${entries[@]}")

	echo
	for entry in "${entries[@]}"; do
		keymap_print_entry "$entry" "$max_command_size"
	done
}
