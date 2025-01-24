function vimium_keymap_extract {
	local keymap_name=$1

	# Open keymap array
	local extracted="$keymap_name=(\n"

	# Populate keymap array
	local seen_first_map
	while IFS= read -r line; do
		# Skip lines until we see the first `map`
		[[ $line == map* ]] && seen_first_map=1
		[[ -z $seen_first_map ]] && continue

		# Convert `line` to keymap format
		# e.g `map a LinkHints.activateMode` -> `a # LinkHints.activateMode`
		if [[ $line == map* ]]; then
			fields=("${=line}")

			# Replace `<>` with `[]` for consistency with all other keymap entries
			fields[2]=${fields[2]/</[}
			fields[2]=${fields[2]/>/]}

			extracted+="\t'${fields[2]} # ${fields[3]}'\n"

		# Preserve empty lines as keymap section separators
		else
			extracted+="\t''\n"
		fi
	done < "$DOTFILES_DIR"/vimium/vimium-keymap.txt

	# Close keymap array
	extracted+=')'

	# Refresh extracted keymap
	echo $extracted > "$VIMIUM_EXTRACTED_KEYMAP"
}
