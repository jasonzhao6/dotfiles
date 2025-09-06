function test__main_keymap {
	assert "$(
		local show_this_help; show_this_help=$(main_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $MAIN_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}; run_with_filter test__main_keymap

function test__main_keymap_g {
	assert "$(mg | bw)" "$(
		cat <<-eof

			Shortcuts: main_keymap.gmail.zsh

			  {enter} # Open conversation
			  e       # Archive
			  R       # Reply
			  A       # Reply all
			  F       # Forward
			  !       # Report as spam
			  u       # Back to threadlist

			  j       # Older conversation
			  k       # Newer conversation
			  x       # Select conversation
			  I       # Mark as read
			  U       # Mark as unread

			  ?       # Show keyboard shortcuts
		eof
	)"
}; run_with_filter test__main_keymap_g

function test__main_keymap_g__with_multiple_words {
	assert "$(mg er con | bw)" "$(
		cat <<-eof

			  j # Older conversation
			  k # Newer conversation
		eof
	)"
}; run_with_filter test__main_keymap_g__with_multiple_words

function test__main_keymap_r {
	assert "$([[ $(main_keymap_r | wc -l) -gt 500 ]] && echo 1)" '1'
}; run_with_filter test__main_keymap_r

function test__main_keymap_r__when_specifying_a_description {
	assert "$(
		main_keymap_r github | bw
	)" "$(
		cat <<-eof

			  $ h.a          # Open the current repo in GitHub Desktop
			  $ m.h <regex>? # Show GitHub Desktop shortcuts
			  $ n.h          # Go to GitHub
			  $ q.h          # Chat with GitHub MCP

			  intellij_alt: alt-o         # Open on GitHub
			  all: h                      # Shell shortcuts: github_keymap.zsh
			  github_desktop: cmd-shift-g # View on GitHub
			  vimium_search: c            # Github Code Search (TENGF)
			  vimium_search: cc           # Github Code Search
			  vimium_search: r            # Github Repo Search (TENGF)
			  vimium_search: rr           # Github Repo Search
		eof
	)"
}; run_with_filter test__main_keymap_r__when_specifying_a_description

function test__main_keymap_r__when_specifying_a_zsh_only_description {
	assert "$(
		main_keymap_r seq | bw
	)" "$(
		cat <<-eof

			  $ a.- <start> <finish> <command> # Use args within a sequence
			  $ o.- <start> <finish> (~~)      # Run a sequence of commands
		eof
	)"
}; run_with_filter test__main_keymap_r__when_specifying_a_zsh_only_description

function test__main_keymap_r__when_specifying_a_non_zsh_only_description {
	assert "$(
		main_keymap_r goog | bw
	)" "$(
		cat <<-eof

			  vimium_search: g  # Google Gmail
			  vimium_search: gc # Google Calendar
			  vimium_search: gd # Google Drive
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
		main_keymap_w j | bw
	)" "$(
		cat <<-eof

		  $ k.j <type> <name>             # Get resource as json & save a copy
		  $ k.jj                          # Get the copy of json
		  $ o.j <url> <regex> <num lines> # Curl a json endpoint

		  alt-j # Step over
		  cmd-j # Join lines
		eof
	)"
}; run_with_filter test__main_keymap_w__when_specifying_a_key

function test__main_keymap_w__when_specifying_a_special_char {
	assert "$(
		main_keymap_w - | bw
	)" "$(
		cat <<-eof

		  $ a.- <start> <finish> <command> # Use args within a sequence
		  $ m.-                            # Show stats
		  $ n.-                            # Sort subfolders by size
		  $ o.- <start> <finish> (~~)      # Run a sequence of commands

		  ^cmd--       # Collapse all
		  cmd--        # Decrease font size in all editors (Convention)
		  ctrl--       # Copilot show chat
		  ctrl-shift-- # Copilot new conversation
		eof
	)"
}; run_with_filter test__main_keymap_w__when_specifying_a_special_char
