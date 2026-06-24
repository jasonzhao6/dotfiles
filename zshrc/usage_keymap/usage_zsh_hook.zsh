KEYMAP_USAGE_FILE="$ZSHRC_DATA_DIR/usage.tsv"
zmodload zsh/datetime # Use $EPOCHSECONDS (to avoid forking `gdate` on every invocation)

function keymap_track_usage {
	local first_word="${1%% *}"
	# shellcheck disable=SC2154 # aliases is a zsh builtin (the alias table)
	[[ ${aliases[$first_word]} == *_keymap* ]] || return

	# `%z` offset (e.g. -0700) lets `uh` recover the wall-clock hour at capture.
	# Computed via the `strftime` builtin to keep the no-fork rationale above.
	local offset; strftime -s offset '%z' "$EPOCHSECONDS"
	printf '%s\t%s\t%s\n' "$EPOCHSECONDS" "$first_word" "$offset" >> "$KEYMAP_USAGE_FILE"
}

if [[ -z $ZSHRC_UNDER_TESTING ]]; then
	autoload -Uz add-zsh-hook
	add-zsh-hook preexec keymap_track_usage
fi
