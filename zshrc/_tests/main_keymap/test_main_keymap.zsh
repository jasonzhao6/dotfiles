function test__main_keymap {
	assert "$(
		local show_this_help; show_this_help=$(main_keymap | grep help | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $MAIN_ALIAS +# Show this help$" ]] && echo 1
	)" '1'
}; run_with_filter test__main_keymap

function test__main_keymap_w {
	assert "$([[ $(main_keymap_w | wc -l) -gt 200 ]] && echo 1)" '1'
}; run_with_filter test__main_keymap_w

function test__main_keymap_w__when_specifying_a_key {
	assert "$([[ $(main_keymap_w k | wc -l) -gt 3 ]] && echo 1)" '1'
}; run_with_filter test__main_keymap_w__when_specifying_a_key

function test__main_keymap_w__when_specifying_a_namespace_and_key {
	assert "$(
		main_keymap_w m w | bw
	)" "$(
		cat <<-eof

		  $ m.w               # List all keymap entries
		  $ m.w <key>         # Filter all keymap entries by <key>
		  $ m.w <alias> <key> # Filter all keymap entries by <alias> and <key>
		eof
	)"
}; run_with_filter test__main_keymap_w__when_specifying_a_namespace_and_key

function test__main_keymap_w__when_specifying_a_namespace_and_special_char {
	assert "$(
		main_keymap_w o , | bw
	)" "$(
		cat <<-eof

		  $ o., # Open \`1.txt\` and \`1.txt\` in TextMate
		eof
	)"
}; run_with_filter test__main_keymap_w__when_specifying_a_namespace_and_special_char
