function test__github_keymap {
	assert "$(
		local show_this_help; show_this_help=$(github_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $GITHUB_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__github_keymap_branch {
	assert "$(nav_keymap_s > /dev/null; github_keymap_branch)" 'main'
}

function test__github_keymap_domain {
	assert "$(nav_keymap_s > /dev/null; github_keymap_domain)" 'github.com'
}

function test__github_keymap_h__single_match_cds {
	assert "$(github_keymap_h dotfiles > /dev/null; pwd)" "$HOME/GitHub/jasonzhao6/dotfiles"
}

function test__github_keymap_h__multiple_matches_stay {
	assert "$(github_keymap_h jasonzhao6 > /dev/null; pwd)" "$HOME/GitHub"
}

function test__github_keymap_h__no_match_stays {
	assert "$(github_keymap_h zzz-no-such-repo > /dev/null; pwd)" "$HOME/GitHub"
}

function test__github_keymap_org {
	assert "$(nav_keymap_s > /dev/null; github_keymap_org)" 'jasonzhao6'
}

function test__github_keymap_repo {
	assert "$(nav_keymap_s > /dev/null; github_keymap_repo)" 'scratch'
}
