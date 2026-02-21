function test__claude_keymap {
	assert "$(
		local show_this_help; show_this_help=$(claude_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $CLAUDE_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}; run_with_filter test__claude_keymap
