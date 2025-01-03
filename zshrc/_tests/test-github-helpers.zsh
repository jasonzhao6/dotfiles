function test--domain {
	assert "$(cds; domain)" 'github.com'
}; run-with-filter test--domain

function test--org {
	assert "$(cds; org)" 'jasonzhao6'
}; run-with-filter test--org

function test--repo {
	assert "$(cds; repo)" 'scratch'
}; run-with-filter test--repo

function test--branch {
	assert "$(cds; branch)" 'main'
}; run-with-filter test--branch
