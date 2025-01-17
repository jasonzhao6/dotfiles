function main_keymap_find_all {
	local current_alias

	find "$ZSHRC_DIR" -maxdepth 1 -name '*_keymap.zsh' | sort | while IFS= read -r file; do
		current_namespace=$(pgrep --only-matching "(?<=_NAMESPACE=')\w+(?=')" "$file")

		# Exclude `_keymap.zsh` helpers with the clue that it doesn't have a namespace
		[[ -z $current_namespace ]] && continue

		current_alias=$(pgrep --only-matching "(?<=_ALIAS=')\w+(?=')" "$file")
		echo "$current_alias # Show \`$current_namespace\`" | bw
	done
}
