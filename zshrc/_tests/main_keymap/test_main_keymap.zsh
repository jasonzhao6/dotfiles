function test__main_keymap {
	assert "$(
		local show_this_help; show_this_help=$(main_keymap | grep help | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $MAIN_ALIAS +# Show this help$" ]] && echo 1
	)" '1'
}; run_with_filter test__main_keymap

function test__main_keymap_r {
	assert "$([[ $(main_keymap_r | wc -l) -gt 500 ]] && echo 1)" '1'
}; run_with_filter test__main_keymap_r

function test__main_keymap_r__when_specifying_a_description {
	assert "$(
		main_keymap_r github | bw
	)" "$(
		cat <<-eof

			  $ n.h # Go to github

			  intellij_alt: alt-o # Open on GitHub
			  vimium_search: h    # Github Search
			  vimium_search: hh   # Github Search (TENGF)
			  vimium_search: hr   # Github Repos
		eof
	)"
}; run_with_filter test__main_keymap_r__when_specifying_a_description

function test__main_keymap_r__when_specifying_a_zsh_only_description {
	assert "$(
		main_keymap_r seq | bw
	)" "$(
		cat <<-eof

			  $ a.e {start} {finish} {command} # Use args within a sequence
			  $ o.e {start} {finish} {~~}      # Run a sequence of commands
		eof
	)"
}; run_with_filter test__main_keymap_r__when_specifying_a_zsh_only_description

function test__main_keymap_r__when_specifying_a_non_zsh_only_description {
	assert "$(
		main_keymap_r goog | bw
	)" "$(
		cat <<-eof

			  vimium_search: gc # Google Calendar
			  vimium_search: gd # Google Drive
			  vimium_search: gg # Google Gmail
			  vimium_search: gi # Google Images
			  vimium_search: gm # Google Maps
		eof
	)"
}; run_with_filter test__main_keymap_r__when_specifying_a_non_zsh_only_description

function test__main_keymap_w {
	assert "$(main_keymap_w)" "$(
		cat <<-eof

			$(red_bar 'key required')
		eof
	)"
}; run_with_filter test__main_keymap_w

function test__main_keymap_w__when_specifying_a_key {
	assert "$(
		main_keymap_w q | bw
	)" "$(
		cat <<-eof

		  $ t.qa # Apply & auto-approve

		  alt-q # Step over
		  cmd-q # Quit (Default)
		eof
	)"
}; run_with_filter test__main_keymap_w__when_specifying_a_key

function test__main_keymap_w__when_specifying_a_special_char {
	assert "$(
		main_keymap_w , | bw
	)" "$(
		cat <<-eof

		  $ s., # MQ restore
		  $ d., # Login with AWS credentials
		  $ m., # Show stats
		  $ o., # Open \`1.txt\` and \`2.txt\` in TextMate

		  alt-, # Collapse (\`{F3}\`)
		  cmd-, # Preferences (Convention)
		eof
	)"
}; run_with_filter test__main_keymap_w__when_specifying_a_special_char
