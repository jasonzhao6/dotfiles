function test__kubectl_keymap {
	assert "$(
		local show_this_help; show_this_help=$(kubectl_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $KUBECTL_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}; run_with_filter test__kubectl_keymap
