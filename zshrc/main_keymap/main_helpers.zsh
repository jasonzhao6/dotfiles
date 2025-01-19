function main_keymap_find_keymaps_by_type {
	local type=$1 # Valid values: `[zsh, non-zsh]`

	local is_zsh_keymap
	local current_namespace
	local current_alias

	keymap_files | while IFS= read -r file; do
		# Zsh keymaps have a `_DOT` variable used by key mappings
		is_zsh_keymap=$(pgrep --only-matching "[A-Z]+_DOT=\"" "$file")

		# Print only keymaps of the specified `type`
		[[ -z $is_zsh_keymap && $type == 'zsh' ]] && continue
		[[ -n $is_zsh_keymap && $type == 'non-zsh' ]] && continue

		current_namespace=$(pgrep --only-matching "(?<=_NAMESPACE=')\w+(?=')" "$file")
		current_alias=$(pgrep --only-matching "(?<=_ALIAS=')\w+(?=')" "$file")

		echo "$current_alias # Show \`$current_namespace\`" | bw
	done
}

function main_keymap_print_default_shortcuts {
	local keymap_name=$1; shift
	local keymap_entries=("$@")

	local max_command_size
	max_command_size=$(keymap_get_max_command_size "${keymap_entries[@]}")

	echo
	echo "$keymap_name" shortcuts
	echo

	for entry in "${keymap_entries[@]}"; do
		keymap_print_entry "$entry" "$max_command_size"
	done
}
