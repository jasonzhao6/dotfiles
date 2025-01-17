function main_keymap_find_all {
	local current_alias

	find "$ZSHRC_DIR" -maxdepth 1 -name '*_keymap.zsh' | sort | while IFS= read -r file; do
		current_namespace=$(pgrep --only-matching "(?<=_NAMESPACE=')\w+(?=')" "$file")
		current_alias=$(pgrep --only-matching "(?<=_ALIAS=')\w+(?=')" "$file")

		echo "$current_alias # Show \`$current_namespace\`" | bw
	done
}

function main_keymap_print_keyboard_shortcuts {
	local keymap_name=$1; shift
	local keymap_entries=("$@")

	local max_command_size
	max_command_size=$(keymap_get_max_command_size "${keymap_entries[@]}")

	echo
	echo "$keymap_name" Keyboard Shortcuts
	echo

	for entry in "${keymap_entries[@]}"; do
		keymap_print_entry "$entry" "$max_command_size"
	done
}
