function test__docker_keymap {
	assert "$(
		local show_this_help; show_this_help=$(docker_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $DOCKER_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}; run_with_filter test__docker_keymap
