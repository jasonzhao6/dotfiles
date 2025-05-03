function vimium_search_keymap_extract {
	local keymap_name=$1

	# Open keymap array
	local extracted="$keymap_name=(\n"

	# Populate keymap array
	local fields
	while IFS= read -r line; do
		# Convert `line` to keymap format
		# e.g `o: https://golinks.io/%s Go Links` -> `o # Go Links`
		if [[ $line == [a-z-]* ]]; then
			fields=("${=line}")
			extracted+="\t'${fields[1]//:} # ${fields[3, -1]}'\n"

		# Preserve empty lines as keymap section separators
		else
			extracted+="\t''\n"
		fi
	done < "$DOTFILES_DIR"/vimium/vimium-search-keymap.txt

	# Close keymap array
	extracted+=')'

	# Refresh extracted keymap
	echo $extracted > "$VIMIUM_SEARCH_KEYMAP_FILE"
}
