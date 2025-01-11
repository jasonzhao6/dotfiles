function test__aws_keymap_o {
	assert "$(
		aws_keymap_o
	)" "$(
		cat <<-eof
		     1	non-secret-placeholder-1  url-1
		     2	non-secret-placeholder-2  url-2
		eof
	)"
}; run_with_filter test__aws_keymap_o

function test__aws_keymap_o__when_filtering_for_2 {
	assert "$(
		aws_keymap_o 2
	)" "$(
		cat <<-eof
		     1	non-secret-placeholder-$(grep_color 2)  url-$(grep_color 2)
		eof
	)"
}; run_with_filter test__aws_keymap_o__when_filtering_for_2
