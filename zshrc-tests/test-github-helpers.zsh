function test_branch {
	local output=$(cds; branch)
	local expected='main'

	[[ $output == $expected ]] && pass || fail 'test_branch'
}; test_branch

function test_domain {
	local output=$(cds; domain)
	local expected='github.com'

	[[ $output == $expected ]] && pass || fail 'test_domain'
}; test_domain

function test_org {
	local output=$(cds; org)
	local expected='jasonzhao6'

	[[ $output == $expected ]] && pass || fail 'test_org'
}; test_org

function test_repo {
	local output=$(cds; repo)
	local expected='scratch'

	[[ $output == $expected ]] && pass || fail 'test_repo'
}; test_repo
