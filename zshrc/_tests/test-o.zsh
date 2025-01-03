function test--o {
	local usage='o test <arg1> <arg2>'
	assert "$(O_UNDER_TEST=1 o | grep --only-matching "$usage")" "$(grep-color "$usage")"
}; run-with-filter test--o

function test--o--with-type {
	assert "$(
		O_UNDER_TEST=1 o test 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run-with-filter test--o--with-type

function test--o--with-type-prefix {
	assert "$(
		O_UNDER_TEST=1 o tes 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run-with-filter test--o--with-type-prefix
