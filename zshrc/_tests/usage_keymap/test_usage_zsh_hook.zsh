function test__keymap_track_usage {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__keymap_track_usage.tsv
		: > "$KEYMAP_USAGE_FILE"

		keymap_track_usage 'gd some args'

		# Should have written one line with alias 'gd'
		awk -F'\t' '{print $2}' "$KEYMAP_USAGE_FILE"

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" 'gd'
}; run_with_filter test__keymap_track_usage

function test__keymap_track_usage__timestamp_format {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__keymap_track_usage__ts.tsv
		: > "$KEYMAP_USAGE_FILE"

		keymap_track_usage 'gd'

		# Field 1 should be a valid epoch (10+ digit number)
		awk -F'\t' '$1 ~ /^[0-9]{10,}$/ {print "valid"}' "$KEYMAP_USAGE_FILE"

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" 'valid'
}; run_with_filter test__keymap_track_usage__timestamp_format

function test__keymap_track_usage__non_keymap {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__keymap_track_usage__non_keymap.tsv
		: > "$KEYMAP_USAGE_FILE"

		keymap_track_usage 'ls -la'

		# Should not have written anything (ls is not a keymap alias)
		wc -c < "$KEYMAP_USAGE_FILE" | tr -d ' '

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '0'
}; run_with_filter test__keymap_track_usage__non_keymap
