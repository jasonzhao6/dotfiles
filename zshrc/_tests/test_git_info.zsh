function test__domain {
	assert "$(nav_keymap_s; domain)" 'github.com'
}; run_with_filter test__domain

function test__org {
	assert "$(nav_keymap_s; org)" 'jasonzhao6'
}; run_with_filter test__org

function test__repo {
	assert "$(nav_keymap_s; repo)" 'scratch'
}; run_with_filter test__repo

function test__branch {
	assert "$(nav_keymap_s; branch)" 'main'
}; run_with_filter test__branch
