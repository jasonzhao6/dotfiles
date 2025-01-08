function test__wo {
	assert "$(
		wo
	)" "$(
		cat <<-eof
		     1	non-secret-placeholder-1  url-1
		     2	non-secret-placeholder-2  url-2
		eof
	)"
}; run_with_filter test__wo

function test__wo__when_filtering_for_2 {
	assert "$(
		wo 2
	)" "$(
		cat <<-eof
		     1	non-secret-placeholder-2  url-2
		eof
	)"
}; run_with_filter test__wo__when_filtering_for_2
