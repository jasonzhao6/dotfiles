function test__aws_keymap {
	assert "$(
		local show_this_help; show_this_help=$(aws_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $AWS_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}; run_with_filter test__aws_keymap

function test__aws_keymap_c {	assert "$(
		aws_keymap_c
		pbpaste
	)" "$(
		cat <<-eof

			$(green_bar History bindings copied to pasteboard)
			bind '"\e[A": history-search-backward'
			bind '"\e[B": history-search-forward'
		eof
	)"
}; run_with_filter test__aws_keymap_c

function test__aws_keymap_s {
	assert "$(
		aws_keymap_s
	)" "$(
		cat <<-eof
		     1	role_name_1  request_page_url_1
		     2	role_name_2  request_page_url_2
		eof
	)"
}; run_with_filter test__aws_keymap_s

function test__aws_keymap_s__when_filtering_for_2 {
	assert "$(
		aws_keymap_s -1
	)" "$(
		cat <<-eof
		     1	role_name_2  request_page_url_2
		eof
	)"
}; run_with_filter test__aws_keymap_s__when_filtering_for_2
