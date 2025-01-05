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

function test__no_color__for_diff {
	assert "$(no_color; which diff)" '/usr/bin/diff'
}; run_with_filter test__no_color__for_diff

function test__no_color__for_egrep {
	assert "$(no_color; which egrep)" '/usr/bin/egrep'
}; run_with_filter test__no_color__for_egrep

function test__no_color__for_grep {
	assert "$(no_color; which grep)" '/usr/bin/grep'
}; run_with_filter test__no_color__for_grep

function test__no_color__for_ls {
	assert "$(no_color; which ls)" '/bin/ls'
}; run_with_filter test__no_color__for_ls
