# Skip: Not interesting to test
# function other_keymap_a

function test__other_keymap_b {
	assert "$(
		other_keymap_b
		pbpaste
	)" "$(
		cat <<-eof
			bind '"\e[A": history-search-backward'
			bind '"\e[B": history-search-forward'
		eof
	)"
}; run_with_filter test__other_keymap_b

# Skip: Cannot test b/c `fc -l` throws 'no such event' error
# function other_keymap_c

# Skip: Cannot test b/c `fc -l` throws 'no such event' error
# function other_keymap_cc

function test__other_keymap_ds {
	local old; old=$(
		cat <<-eof
			This is the original content.
			Line 1
			Line 2
			Line 3
			Line 4
		eof
	)

	local new; new=$(
		cat <<-eof
			This is the modified content.
			Line 1
			Line 2
			Line 3
			New Line
			Line 4
		eof
	)

	assert "$(
		other_keymap_ds <(echo "$old") <(echo "$new") | bw
	)" "$(
		cat <<-eof
			This is the original content.                                   |       This is the modified content.
			                                                                >       New Line
		eof
	)"
}; run_with_filter test__other_keymap_ds

function test__other_keymap_du {
	local old; old=$(
		cat <<-eof
			This is the original content.
			Line 1
			Line 2
			Line 3
			Line 4
		eof
	)

	local new; new=$(
		cat <<-eof
			This is the modified content.
			Line 1
			Line 2
			Line 3
			New Line
			Line 4
		eof
	)

	assert "$(
		other_keymap_du <(echo "$old") <(echo "$new") | bw | sed 1,2d
	)" "$(
		cat <<-eof
			@@ -1,5 +1,6 @@
			-This is the original content.
			+This is the modified content.
			 Line 1
			 Line 2
			 Line 3
			+New Line
			 Line 4
		eof
	)"
}; run_with_filter test__other_keymap_du

# Skip: Not interesting to test
# function other_keymap_i

# Skip: Not interesting to test
# function other_keymap_m

# Skip: Not interesting to test
# function other_keymap_o

# Skip: Not interesting to test
# function other_keymap_p

# Skip: Not interesting to test
# function other_keymap_pp

# Skip: Not interesting to test
# function other_keymap_s

# Skip: Not interesting to test
# function other_keymap_t
