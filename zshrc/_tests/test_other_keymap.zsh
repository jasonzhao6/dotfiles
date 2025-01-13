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

function test__other_keymap_d {
	assert "$(
		ZSHRC_UNDER_TESTING=1 od www.google.com
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run_with_filter test__other_keymap_d

function test__other_keymap_d__without_input {
	assert "$(ZSHRC_UNDER_TESTING=1 od)" ''
}; run_with_filter test__other_keymap_d__without_input

function test__other_keymap_d__with_protocol {
	assert "$(
		ZSHRC_UNDER_TESTING=1 od https://www.google.com
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run_with_filter test__other_keymap_d__with_protocol

function test__other_keymap_d__with_protocol_and_path {
	assert "$(
		ZSHRC_UNDER_TESTING=1 od https://www.google.com/path/to/page
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run_with_filter test__other_keymap_d__with_protocol_and_path

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

# Skip: Not testing b/c requires network call
# function other_keymap_f

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

function test__other_keymap_q {
	assert "$(
		other_keymap_q 3 4 echo ~~ 2>&1
	)" "$(
		cat <<-eof

			echo 3
			3

			echo 4
			4
		eof
	)"
}; run_with_filter test__other_keymap_q

function test__other_keymap_q__with_multiple_substitutions {
	assert "$(
		other_keymap_q 3 4 echo ~~ and ~~ again 2>&1
	)" "$(
		cat <<-eof

			echo 3 and 3 again
			3 and 3 again

			echo 4 and 4 again
			4 and 4 again
		eof
	)"
}; run_with_filter test__other_keymap_q__with_multiple_substitutions

function test__other_keymap_q__with_multiple_substitutions_in_quotes {
	assert "$(
		other_keymap_q 3 4 'echo ~~ and ~~ again' 2>&1
	)" "$(
		cat <<-eof

			echo 3 and 3 again
			3 and 3 again

			echo 4 and 4 again
			4 and 4 again
		eof
	)"
}; run_with_filter test__other_keymap_q__with_multiple_substitutions_in_quotes

function test__other_keymap_q__with_math {
	assert "$(
		other_keymap_q 3 4 echo ~~ and '$((~~ + 10))' too 2>&1
	)" "$(
		cat <<-eof

			echo 3 and \$((3 + 10)) too
			3 and 13 too

			echo 4 and \$((4 + 10)) too
			4 and 14 too
		eof
	)"
}; run_with_filter test__other_keymap_q__with_math

function test__other_keymap_r {
	assert "$(
		rm -rf /tmp/test__other_keymap_r
		mkdir /tmp/test__other_keymap_r
		cd /tmp/test__other_keymap_r || return
		touch 1.log 2.log 3.txt
		other_keymap_r log txt
		ls
		rm -rf /tmp/test__other_keymap_r
	)" "$(
		cat <<-eof
			1.txt
			2.txt
			3.txt
		eof
	)"
}; run_with_filter test__other_keymap_r

# Skip: Not interesting to test
# function other_keymap_s

# Skip: Not interesting to test
# function other_keymap_t
