function test__github_keymap_nb {
	assert "$(nav_keymap_s > /dev/null; github_keymap_nb)" 'main'
}; run_with_filter test__github_keymap_nb

function test__github_keymap_nd {
	assert "$(nav_keymap_s > /dev/null; github_keymap_nd)" 'github.com'
}; run_with_filter test__github_keymap_nd

function test__github_keymap_no {
	assert "$(nav_keymap_s > /dev/null; github_keymap_no)" 'jasonzhao6'
}; run_with_filter test__github_keymap_no

function test__github_keymap_nr {
	assert "$(nav_keymap_s > /dev/null; github_keymap_nr)" 'scratch'
}; run_with_filter test__github_keymap_nr
