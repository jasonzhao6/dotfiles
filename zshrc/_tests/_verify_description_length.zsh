# This section (2) counts every entry with a `# ` description.
# Sections 3/4 count implementation functions instead.
# The extra ones here come from entries that have descriptions but no
# corresponding function: reserved entries, joint duplicates (same key,
# different args like `a.w` / `a.w <letter>`), and bare alias entries
# (using `_ALIAS` instead of `_DOT`).

function verify_description_length_section {
	local section_number=$1

	echo
	echo
	echo "$section_number: Verify keymap descriptions are at most 40 characters"

	init

	for keymap_file in $(keymap_files); do
		verify_description_length "$keymap_file"
	done

	print_summary 'keymap descriptions are at most 40 characters'
}

function verify_description_length {
	local keymap_file=$1

	# Skip app shortcut reference files (e.g. intellij_keymaps/, vimium_keymaps/)
	# Real keymaps live in a directory matching their filename (e.g. git_keymap/git_keymap.zsh)
	local basename; basename=$(basename "$keymap_file" .zsh)
	local dirname; dirname=$(basename "$(dirname "$keymap_file")")
	[[ $dirname != "$basename" ]] && return

	local namespace
	namespace=$(pgrep --only-matching "(?<=_NAMESPACE=')\w+(?=')" "$keymap_file" | bw)
	local upper_ns="${namespace:u}"
	local entries=("${(P@)upper_ns}")

	local entry desc
	for entry in "${entries[@]}"; do
		# Skip empty lines and comment lines
		[[ -z $entry ]] && continue
		[[ $entry == \#* ]] && continue

		# Skip entries without descriptions
		[[ $entry != *' # '* ]] && continue

		# Extract description (text after " # ")
		desc="${entry#*# }"

		if [[ ${#desc} -le 40 ]]; then
			pass
		else
			fail "'$desc' is ${#desc} chars (max 40)"
		fi
	done
}
