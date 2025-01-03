function test--t {
	local usage='t t_test <arg1> <arg2>'
	assert "$(t | grep --only-matching "$usage")" "$(grep-color "$usage")"
}; run-with-filter test--t

function test--t--with-type {
	assert "$(
		t t_test 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run-with-filter test--t--with-type

function test--t--with-type-prefix {
	assert "$(
		t t_tes 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run-with-filter test--t--with-type-prefix

function test--opal {
	assert "$(
		opal
	)" "$(
		cat <<-eof
		     1	non-secret-placeholder-1  url-1
		     2	non-secret-placeholder-2  url-2
		     3	non-secret-placeholder-3  url-3
		eof
	)"
}; run-with-filter test--opal
