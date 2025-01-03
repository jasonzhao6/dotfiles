function test__domain {
	assert "$(cds; domain)" 'github.com'
}; run_with_filter test__domain

function test__org {
	assert "$(cds; org)" 'jasonzhao6'
}; run_with_filter test__org

function test__repo {
	assert "$(cds; repo)" 'scratch'
}; run_with_filter test__repo

function test__branch {
	assert "$(cds; branch)" 'main'
}; run_with_filter test__branch
