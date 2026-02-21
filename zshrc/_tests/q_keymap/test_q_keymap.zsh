function test__q_keymap {
	assert "$(
		local show_this_help; show_this_help=$(q_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $Q_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}; run_with_filter test__q_keymap
