function test__t {
	local usage='t t_test <arg1> <arg2>'
	assert "$(t | grep --only-matching "$usage")" "$(grep_color "$usage")"
}; run_with_filter test__t

function test__t__with_type {
	assert "$(
		t t_test 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run_with_filter test__t__with_type

function test__t__with_type_prefix {
	assert "$(
		t t_tes 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run_with_filter test__t__with_type_prefix

function test__opal {
	assert "$(
		opal
	)" "$(
		cat <<-eof
		     1	non-secret-placeholder-1  url-1
		     2	non-secret-placeholder-2  url-2
		     3	non-secret-placeholder-3  url-3
		eof
	)"
}; run_with_filter test__opal
