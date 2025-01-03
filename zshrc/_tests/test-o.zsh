function test--o {
	local usage='o o-test <arg1> <arg2>'
	assert "$(o | grep --only-matching "$usage")" "$(grep-color "$usage")"
}; run-with-filter test--o

function test--o--with-type {
	assert "$(
		o o-test 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run-with-filter test--o--with-type

function test--o--with-type-prefix {
	assert "$(
		o o-tes 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run-with-filter test--o--with-type-prefix
