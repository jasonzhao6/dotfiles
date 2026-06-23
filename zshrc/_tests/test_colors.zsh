function test__color__for_diff {
	assert "$(color; which diff)" 'diff: aliased to colordiff'
}

function test__color__for_grep {
	assert "$(color; which grep)" 'grep: aliased to grep --color=always'
}

function test__color__for_grepE {
	assert "$(color; which grepE)" 'grepE: aliased to grep -E --color=always'
}

function test__color__for_ls {
	assert "$(color; which ls)" 'ls: aliased to ls --color=always'
}

function test__no_color__for_diff {
	assert "$(no_color; which diff)" '/usr/bin/diff'
}

function test__no_color__for_grep {
	assert "$(no_color; which grep)" '/usr/bin/grep'
}

function test__no_color__for_grepE {
	assert "$(no_color; which grepE)" 'grepE not found'
}

function test__no_color__for_ls {
	assert "$(no_color; which ls)" '/bin/ls'
}
