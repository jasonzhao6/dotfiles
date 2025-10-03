function test__github_keymap {
	assert "$(
		local show_this_help; show_this_help=$(github_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $GITHUB_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}; run_with_filter test__github_keymap

function test__github_keymap_branch {
	assert "$(nav_keymap_s > /dev/null; github_keymap_branch)" 'main'
}; run_with_filter test__github_keymap_branch

function test__github_keymap_domain {
	assert "$(nav_keymap_s > /dev/null; github_keymap_domain)" 'github.com'
}; run_with_filter test__github_keymap_domain

function test__github_keymap_org {
	assert "$(nav_keymap_s > /dev/null; github_keymap_org)" 'jasonzhao6'
}; run_with_filter test__github_keymap_org

function test__github_keymap_repo {
	assert "$(nav_keymap_s > /dev/null; github_keymap_repo)" 'scratch'
}; run_with_filter test__github_keymap_repo
