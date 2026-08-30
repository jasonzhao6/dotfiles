# A throwaway repo with a known remote, so URL assertions don't depend on this
# repo's push state. Callers fake the remote-tracking ref when they need a
# pushed HEAD: `update-ref` satisfies `git branch -r --contains` with no network
function github_test_repo {
	local tmp_dir; tmp_dir=$(mktemp -d)

	# `:A` resolves `/var` to `/private/var`, so `pwd` matches `--show-toplevel`
	tmp_dir=${tmp_dir:A}

	git -C "$tmp_dir" init --quiet 2> /dev/null
	git -C "$tmp_dir" remote add origin https://github.com/acme/widgets.git
	echo 'hi' > "$tmp_dir/file.txt"
	git -C "$tmp_dir" add file.txt
	git -C "$tmp_dir" commit --quiet -m 'test'

	echo "$tmp_dir"
}

function test__github_keymap__non_path_arg_searches_keymap {
	assert "$(github_keymap org | grep --count 'Org name')" '1'
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

function test__github_keymap_o__dot_opens_at_sha {
	local tmp_dir; tmp_dir=$(github_test_repo)
	git -C "$tmp_dir" update-ref refs/remotes/origin/main HEAD

	assert "$(
		cd "$tmp_dir" || return
		github_keymap_o .
	)" "https://github.com/acme/widgets/tree/$(git -C "$tmp_dir" rev-parse HEAD)"

	rm -rf "$tmp_dir"
}

function test__github_keymap_o__file_opens_at_sha {
	local tmp_dir; tmp_dir=$(github_test_repo)
	git -C "$tmp_dir" update-ref refs/remotes/origin/main HEAD

	assert "$(
		cd "$tmp_dir" || return
		github_keymap_o file.txt
	)" "https://github.com/acme/widgets/blob/$(git -C "$tmp_dir" rev-parse HEAD)/file.txt"

	rm -rf "$tmp_dir"
}

function test__github_keymap_o__org_repo_opens_remote {
	local tmp_dir; tmp_dir=$(github_test_repo)

	assert "$(
		cd "$tmp_dir" || return
		function open { echo "$1"; }
		github_keymap_o some-org/some-repo
	)" 'https://github.com/some-org/some-repo'

	rm -rf "$tmp_dir"
}

function test__github_keymap_o__with_unpushed_commit {
	local tmp_dir; tmp_dir=$(github_test_repo)

	assert "$(
		cd "$tmp_dir" || return
		github_keymap_o .
	)" "$(red_bar "Commit $(git -C "$tmp_dir" rev-parse HEAD) not pushed yet")"

	rm -rf "$tmp_dir"
}

function test__github_keymap_oo__dot_opens_at_main {
	local url
	nav_keymap_d > /dev/null
	url=$(github_keymap_oo .)
	assert "$url" "https://github.com/jasonzhao6/dotfiles/tree/main"
}

function test__github_keymap_oo__file_opens_at_main {
	local url
	nav_keymap_d > /dev/null
	url=$(github_keymap_oo README.md)
	assert "$url" "https://github.com/jasonzhao6/dotfiles/blob/main/README.md"
}

function test__github_keymap_org {
	assert "$(nav_keymap_s > /dev/null; github_keymap_org)" 'jasonzhao6'
}

function test__github_keymap_repo {
	assert "$(nav_keymap_s > /dev/null; github_keymap_repo)" 'scratch'
}
