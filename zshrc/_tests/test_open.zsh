function test__o {
	local usage='o open_test <arg1> <arg2>'
	assert "$(o | grep --only-matching "$usage")" "$(grep_color "$usage")"
}; run_with_filter test__o

function test__o__with_type {
	assert "$(
		o open_test 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run_with_filter test__o__with_type

function test__o__with_type_prefix {
	assert "$(
		o open_tes 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run_with_filter test__o__with_type_prefix
