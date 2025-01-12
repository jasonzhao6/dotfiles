function test__github_keymap_b {
	assert "$(nav_keymap_s > /dev/null; github_keymap_b)" 'main'
}; run_with_filter test__github_keymap_b

function test__github_keymap_d {
	assert "$(nav_keymap_s > /dev/null; github_keymap_d)" 'github.com'
}; run_with_filter test__github_keymap_d

function test__github_keymap_o {
	assert "$(nav_keymap_s > /dev/null; github_keymap_o)" 'jasonzhao6'
}; run_with_filter test__github_keymap_o

function test__github_keymap_r {
	assert "$(nav_keymap_s > /dev/null; github_keymap_r)" 'scratch'
}; run_with_filter test__github_keymap_r
