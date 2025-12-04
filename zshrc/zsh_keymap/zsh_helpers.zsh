function zsh_keymap_does_key_exist {
	local key=$1

	local keymaps; keymaps=$(main_keymap_grep_keymap_names)
	local keymap_entries

	# shellcheck disable=SC2034 # Used to define `keymap_entries`
	while IFS= read -r keymap; do
		# shellcheck disable=SC2206 # Adding double quote breaks array expansion
		# shellcheck disable=SC2296 # Allow zsh-specific param expansion
		keymap_entries=(${(P)keymap})

		# Zsh keymaps have a dot alias; skip non-zsh keymaps
		keymap_has_dot_alias "${keymap_entries[@]}" || continue

		# Find a keymap entry with matching key
		for entry in "${keymap_entries[@]}"; do
			[[ $entry =~ $key ]] && return 0
		done
	done <<< "$keymaps"

	return 1
}
