function test__github_keymap {
	assert "$(
		local show_this_help; show_this_help=$(github_keymap | grep help | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $GITHUB_ALIAS +# Show this help$" ]] && echo 1
	)" '1'
}; run_with_filter test__github_keymap

function test__github_keymap_b {
	assert "$(nav_keymap_s > /dev/null; github_keymap_b)" 'main'
}; run_with_filter test__github_keymap_b

function test__github_keymap_d {
	assert "$(nav_keymap_s > /dev/null; github_keymap_d)" 'github.com'
}; run_with_filter test__github_keymap_d

function test__github_keymap_oo {
	assert "$(nav_keymap_s > /dev/null; github_keymap_oo)" 'jasonzhao6'
}; run_with_filter test__github_keymap_oo

function test__github_keymap_rr {
	assert "$(nav_keymap_s > /dev/null; github_keymap_rr)" 'scratch'
}; run_with_filter test__github_keymap_rr
