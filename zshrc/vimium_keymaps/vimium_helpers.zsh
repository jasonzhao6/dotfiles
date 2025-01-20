function vimium_keymap_init {
	local keymap_name=$1

	eval "$keymap_name=()"

	local seen_first_map
	while IFS= read -r line; do
		# Skip lines until we see the first `map`
		[[ $line == map* ]] && seen_first_map=1
		[[ -z $seen_first_map ]] && continue

		# Convert `line` to keymap format
		# e.g `map a LinkHints.activateMode` -> `a # LinkHints.activateMode`
		if [[ $line == map* ]]; then
			# Remove `<` and `>` as `${(z)...}` splits on them
			line=${line//<}
			line=${line//>}

			fields=("${(z)line}")
			eval "$keymap_name+=('${fields[2]} # ${fields[3]}')"

		# Preserve empty lines as keymap section separators
		else
			eval "$keymap_name+=('')"
		fi
	done < "$DOTFILES_DIR"/vimium/vimium-keymap.txt
}
