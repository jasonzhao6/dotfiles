function test__domain {
	assert "$(nav_keymap_s > /dev/null; domain)" 'github.com'
}; run_with_filter test__domain

function test__org {
	assert "$(nav_keymap_s > /dev/null; org)" 'jasonzhao6'
}; run_with_filter test__org

function test__repo {
	assert "$(nav_keymap_s > /dev/null; repo)" 'scratch'
}; run_with_filter test__repo

function test__branch {
	assert "$(nav_keymap_s > /dev/null; branch)" 'main'
}; run_with_filter test__branch
