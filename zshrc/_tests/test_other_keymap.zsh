# Skip: Not interesting to test
# function other_keymap_a

function test__other_keymap_b {
	assert "$(
		other_keymap_b
#		pbpaste
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
