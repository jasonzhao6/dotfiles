function test__git_keymap {
	assert "$(
		local show_this_help; show_this_help=$(git_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ $show_this_help =~ "^  \\$ $GIT_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__git_keymap_ff__with_confirmed {
	assert "$(
		function read { return 0; }
		function git { echo "git $*"; }

		git_keymap_ff 2>&1
	)" "$(
		echo
		echo
		echo
		echo 'git push --force'
	)"
}

function test__git_keymap_ff__with_denied {
	assert "$(
		function read { return 1; }
		function git { echo 'SHOULD NOT BE CALLED'; }

		git_keymap_ff 2>&1
	)" ''
}

function test__git_keymap_lc__with_confirmed {
	assert "$(
		function read { return 0; }
		function git { echo "git $*"; }

		git_keymap_lc 2>&1
	)" "$(
		echo
		echo
		echo
		echo 'git stash clear'
	)"
}

function test__git_keymap_lc__with_denied {
	assert "$(
		function read { return 1; }
		function git { echo 'SHOULD NOT BE CALLED'; }

		git_keymap_lc 2>&1
	)" ''
}

function test__git_keymap_z__with_confirmed {
	assert "$(
		function read { return 0; }
		function git { echo "git $*"; }

		git_keymap_z 2>&1
	)" "$(
		cat <<-eof

			
			
			git add --all
			git reset --hard
			git status
		eof
	)"
}

function test__git_keymap_z__with_commits_confirmed {
	assert "$(
		function read { return 0; }
		function git { echo "git $*"; }
		function git_keymap_u { echo "undo $*"; }

		git_keymap_z 2 2>&1
	)" "$(
		cat <<-eof

			
			
			undo 2
			git add --all
			git reset --hard
			git status
		eof
	)"
}

function test__git_keymap_z__with_denied {
	assert "$(
		function read { return 1; }
		function git { echo 'SHOULD NOT BE CALLED'; }

		git_keymap_z 2>&1
	)" ''
}

function test__git_keymap_zz__with_confirmed {
	assert "$(
		function read { return 0; }
		function git { echo "git $*"; }
		function git_keymap_u { echo "undo $*"; }

		git_keymap_zz 2>&1
	)" "$(
		cat <<-eof

			
			
			undo 1
			git add --all
			git reset --hard
			git status
		eof
	)"
}

function test__git_keymap_zz__with_denied {
	assert "$(
		function read { return 1; }
		function git { echo 'SHOULD NOT BE CALLED'; }

		git_keymap_zz 2>&1
	)" ''
}
