function test__aws_keymap {
	assert "$(
		local show_this_help; show_this_help=$(aws_keymap | grep help | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $AWS_ALIAS +# Show this help$" ]] && echo 1
	)" '1'
}; run_with_filter test__aws_keymap

function test__aws_keymap_o {
	assert "$(
		aws_keymap_o
	)" "$(
		cat <<-eof
		     1	non-secret-placeholder-1   url-1
		     2	non-secret-placeholder-2   url-2
		     3	non-secret-placeholder-20  url-20
		eof
	)"
}; run_with_filter test__aws_keymap_o

function test__aws_keymap_o__when_filtering_for_2 {
	assert "$(
		aws_keymap_o -0 2
	)" "$(
		cat <<-eof
		     1	non-secret-placeholder-$(grep_color 2)   url-$(grep_color 2)
		eof
	)"
}; run_with_filter test__aws_keymap_o__when_filtering_for_2

function test__aws_keymap_z {	assert "$(
		aws_keymap_z
		pbpaste
	)" "$(
		cat <<-eof
		
			History bindings copied to pasteboard
			bind '"\e[A": history-search-backward'
			bind '"\e[B": history-search-forward'
		eof
	)"
}; run_with_filter test__aws_keymap_z
