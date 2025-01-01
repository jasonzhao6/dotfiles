function test--grep-highlighting {
	assert "$(echo 'hello world' | grep ello)" "h$(grep-highlighting ello) world"
}; run-with-filter test--grep-highlighting

function test--bw--for-diff {
	assert "$(
	  bw
		which diff
	)" '/usr/bin/diff'
}; run-with-filter test--bw--for-diff

function test--bw--for-egrep {
	assert "$(
	  bw
		which egrep
	)" '/usr/bin/egrep'
}; run-with-filter test--bw--for-egrep

function test--bw--for-grep {
	assert "$(
	  bw
		which grep
	)" '/usr/bin/grep'
}; run-with-filter test--bw--for-grep

function test--bw--for-ls {
	assert "$(
	  bw
		which ls
	)" '/bin/ls'
}; run-with-filter test--bw--for-ls

function test--color--for-diff {
	assert "$(
	  color
		which diff
	)" 'diff: aliased to colordiff'
}; run-with-filter test--color--for-diff

function test--color--for-egrep {
	assert "$(
	  color
		which egrep
	)" 'egrep: aliased to egrep --color=always'
}; run-with-filter test--color--for-egrep

function test--color--for-grep {
	assert "$(
	  color
		which grep
	)" 'grep: aliased to grep --color=always'
}; run-with-filter test--color--for-grep

function test--color--for-ls {
	assert "$(
	  color
		which ls
	)" 'ls: aliased to ls --color=always'
}; run-with-filter test--color--for-ls
