KEYMAP_USAGE_FILE="$ZSHRC_DATA_DIR/usage.tsv"
zmodload zsh/datetime

function keymap_track_usage {
	local first_word="${1%% *}"
	[[ ${aliases[$first_word]} == *_keymap* ]] || return

	printf '%s\t%s\n' "$EPOCHSECONDS" "$first_word" >> "$KEYMAP_USAGE_FILE"
}

if [[ -z $ZSHRC_UNDER_TESTING ]]; then
	autoload -Uz add-zsh-hook
	add-zsh-hook preexec keymap_track_usage
fi
