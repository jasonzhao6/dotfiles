function zsh_helpers_pbpaste_file_path {
	# Fast path: plain text clipboard (e.g. path copied from terminal)
	local file; file=$(pbpaste | strip)

	# Slow path: Finder copies files as URL references, not plain text,
	# so `pbpaste` only returns the filename; use AppKit to get the full path
	if [[ ! -f $file && -z $ZSHRC_UNDER_TESTING ]]; then
		file=$(osascript -e '
			use framework "AppKit"
			set pb to current application'\''s NSPasteboard'\''s generalPasteboard()
			set fileURLs to pb'\''s readObjectsForClasses:{current application'\''s NSURL} options:(missing value)
			if (count of fileURLs) > 0 then
				return ((item 1 of fileURLs)'\''s |path|()) as text
			end if
		' 2>/dev/null)
	fi

	echo "$file"
}

function zsh_helpers_does_key_exist {
	local key=$1

	local keymaps; keymaps=$(main_helpers_grep_keymap_names)
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
