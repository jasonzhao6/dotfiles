function test__docker_keymap {
	assert "$(
		local show_this_help; show_this_help=$(docker_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ $show_this_help =~ "^  \\$ $DOCKER_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}
