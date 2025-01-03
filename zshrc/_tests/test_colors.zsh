function test__color__for_diff {
	assert "$(color; which diff)" 'diff: aliased to colordiff'
}; run_with_filter test__color__for_diff

function test__color__for_egrep {
	assert "$(color; which egrep)" 'egrep: aliased to egrep --color=always'
}; run_with_filter test__color__for_egrep

function test__color__for_grep {
	assert "$(color; which grep)" 'grep: aliased to grep --color=always'
}; run_with_filter test__color__for_grep

function test__color__for_ls {
	assert "$(color; which ls)" 'ls: aliased to ls --color=always'
}; run_with_filter test__color__for_ls

function test__bw__for_diff {
	assert "$(bw; which diff)" '/usr/bin/diff'
}; run_with_filter test__bw__for_diff

function test__bw__for_egrep {
	assert "$(bw; which egrep)" '/usr/bin/egrep'
}; run_with_filter test__bw__for_egrep

function test__bw__for_grep {
	assert "$(bw; which grep)" '/usr/bin/grep'
}; run_with_filter test__bw__for_grep

function test__bw__for_ls {
	assert "$(bw; which ls)" '/bin/ls'
}; run_with_filter test__bw__for_ls

function test__grep_color {
	assert "$(echo 'hello world' | grep ello)" "h$(grep_color ello) world"
}; run_with_filter test__grep_color
