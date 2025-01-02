function test--t {
	local usage='t test <arg1> <arg2>'
	assert "$(T_UNDER_TEST=1 t | grep --only-matching "$usage")" "$(grep-color "$usage")"
}; run-with-filter test--t

function test--t--with-type {
	assert "$(
		T_UNDER_TEST=1 t test 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run-with-filter test--t--with-type

function test--t--with-type-prefix {
	assert "$(
		T_UNDER_TEST=1 t tes 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run-with-filter test--t--with-type-prefix

function test--t-opal {
	assert "$(
		t-opal
	)" "$(
		cat <<-eof
		     1	non-secret-placeholder1  url1
		     2	non-secret-placeholder2  url2
		     3	non-secret-placeholder3  url3
		eof
	)"
}; run-with-filter test--t-opal
