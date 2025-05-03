function test__other_keymap {
	assert "$(
		local show_this_help; show_this_help=$(other_keymap | grep help | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $OTHER_ALIAS +# Show this help$" ]] && echo 1
	)" '1'
}; run_with_filter test__other_keymap

function test__other_keymap_- {	assert "$(
		other_keymap_- 3 4 echo ~~ 2>&1
	)" "$(
		cat <<-eof

			echo 3
			3

			echo 4
			4
		eof
	)"
}; run_with_filter test__other_keymap_-

function test__other_keymap_-__with_multiple_substitutions {
	assert "$(
		other_keymap_- 3 4 echo ~~ and ~~ again 2>&1
	)" "$(
		cat <<-eof

			echo 3 and 3 again
			3 and 3 again

			echo 4 and 4 again
			4 and 4 again
		eof
	)"
}; run_with_filter test__other_keymap_-__with_multiple_substitutions

function test__other_keymap_-__with_multiple_substitutions_in_quotes {
	assert "$(
		other_keymap_- 3 4 'echo ~~ and ~~ again' 2>&1
	)" "$(
		cat <<-eof

			echo 3 and 3 again
			3 and 3 again

			echo 4 and 4 again
			4 and 4 again
		eof
	)"
}; run_with_filter test__other_keymap_-__with_multiple_substitutions_in_quotes

function test__other_keymap_-__with_math {
	assert "$(
		other_keymap_- 3 4 echo ~~ and '$((~~ + 10))' too 2>&1
	)" "$(
		cat <<-eof

			echo 3 and \$((3 + 10)) too
			3 and 13 too

			echo 4 and \$((4 + 10)) too
			4 and 14 too
		eof
	)"
}; run_with_filter test__other_keymap_-__with_math

function test__other_keymap_b {
	local file; file=$(
		cat <<-eof
			a,50
			b,20
			c,70
			d,40
		eof
	)

	assert "$(
		other_keymap_b <(echo "$file") 2
	)" "$(
		cat <<-eof
			b,20
			d,40
			a,50
			c,70
		eof
	)"
}; run_with_filter test__other_keymap_b

function test__other_keymap_b__when_no_column_index {
	local file; file=$(
		cat <<-eof
			b,20
			d,40
			a,50
			c,70
		eof
	)

	assert "$(
		other_keymap_b <(echo "$file")
	)" "$(
		cat <<-eof
			a,50
			b,20
			c,70
			d,40
		eof
	)"
}; run_with_filter test__other_keymap_b__when_no_column_index

function test__other_keymap_b__when_invoked_after_pipe {
	local file; file=$(
		cat <<-eof
			a,50
			b,20
			c,70
			d,40
		eof
	)

	assert "$(
		echo "$file" | other_keymap_b 2
	)" "$(
		cat <<-eof
			b,20
			d,40
			a,50
			c,70
		eof
	)"
}; run_with_filter test__other_keymap_b__when_invoked_after_pipe

function test__other_keymap_b__when_invoked_after_pipe_and_no_column_index {
	local file; file=$(
		cat <<-eof
			b,20
			d,40
			a,50
			c,70
		eof
	)

	assert "$(
		echo "$file" | other_keymap_b
	)" "$(
		cat <<-eof
			a,50
			b,20
			c,70
			d,40
		eof
	)"
}; run_with_filter test__other_keymap_b__when_invoked_after_pipe_and_no_column_index

function test__other_keymap_d {	assert "$(
		ZSHRC_UNDER_TESTING=1 other_keymap_d www.google.com
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run_with_filter test__other_keymap_d

function test__other_keymap_d__without_input {
	assert "$(ZSHRC_UNDER_TESTING=1 other_keymap_d)" ''
}; run_with_filter test__other_keymap_d__without_input

function test__other_keymap_d__with_protocol {
	assert "$(
		ZSHRC_UNDER_TESTING=1 other_keymap_d https://www.google.com
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run_with_filter test__other_keymap_d__with_protocol

function test__other_keymap_d__with_protocol_and_path {
	assert "$(
		ZSHRC_UNDER_TESTING=1 other_keymap_d https://www.google.com/path/to/page
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run_with_filter test__other_keymap_d__with_protocol_and_path

function test__other_keymap_k {	assert "$(
		OTHER_KEYMAP_K_DIR="/tmp/test__other_keymap_k"
		rm -rf $OTHER_KEYMAP_K_DIR

		echo '$' | pbcopy
		ZSHRC_UNDER_TESTING=1 other_keymap_k
		ls -l $OTHER_KEYMAP_K_DIR | wc -l
		cat $OTHER_KEYMAP_K_DIR/*

		other_keymap_k_reset
		rm -rf $OTHER_KEYMAP_K_DIR
	)" "$(
		cat <<-eof
			       2
			$
		eof
	)"
}; run_with_filter test__other_keymap_k

function test__other_keymap_k__when_dumping_same_pasteboard_twice {
	assert "$(
		OTHER_KEYMAP_K_DIR="/tmp/test__other_keymap_k"
		rm -rf $OTHER_KEYMAP_K_DIR

		echo '$' | pbcopy
		ZSHRC_UNDER_TESTING=1 other_keymap_k
		ZSHRC_UNDER_TESTING=1 other_keymap_k
		ls -l $OTHER_KEYMAP_K_DIR | wc -l
		cat $OTHER_KEYMAP_K_DIR/*

		other_keymap_k_reset
		rm -rf $OTHER_KEYMAP_K_DIR
	)" "$(
		cat <<-eof
			       2
			$
		eof
	)"
}; run_with_filter test__other_keymap_k__when_dumping_same_pasteboard_twice

function test__other_keymap_k__when_dumping_two_different_pasteboards {
	assert "$(
		OTHER_KEYMAP_K_DIR="/tmp/test__other_keymap_k"
		rm -rf $OTHER_KEYMAP_K_DIR

		printf "pasteboard 1\n$\n" | pbcopy
		ZSHRC_UNDER_TESTING=1 other_keymap_k
		printf "pasteboard 2\n$\n" | pbcopy
		ZSHRC_UNDER_TESTING=1 other_keymap_k
		ls -l $OTHER_KEYMAP_K_DIR | wc -l
		cat $OTHER_KEYMAP_K_DIR/*

		other_keymap_k_reset
		rm -rf $OTHER_KEYMAP_K_DIR
	)" "$(
		cat <<-eof
			       3
			pasteboard 1
			$
			pasteboard 2
			$
		eof
	)"
}; run_with_filter test__other_keymap_k__when_dumping_two_different_pasteboards

function test__other_keymap_k__when_not_terminal_output {
	assert "$(
		# shellcheck disable=SC2030
		OTHER_KEYMAP_K_DIR="/tmp/test__other_keymap_k"
		rm -rf $OTHER_KEYMAP_K_DIR

		echo 'not terminal output' | pbcopy
		ZSHRC_UNDER_TESTING=1 other_keymap_k
		ls -l $OTHER_KEYMAP_K_DIR | wc -l

		other_keymap_k_reset
	)" '       1'
}; run_with_filter test__other_keymap_k__when_not_terminal_output

function test__other_keymap_kc {
	assert "$(
		# shellcheck disable=SC2030
		OTHER_KEYMAP_K_DIR="/tmp/test__other_keymap_k"
		mkdir -p $OTHER_KEYMAP_K_DIR

		other_keymap_kc
		[[ -e $OTHER_KEYMAP_K_DIR ]] && echo present || echo absent

		other_keymap_k_reset
	)" 'absent'
}; run_with_filter test__other_keymap_kc

function test__other_keymap_kk {
	# shellcheck disable=SC2031
	assert "$(
		other_keymap_kk
		pwd
	)" "$(
		cat <<-eof

			$OTHER_KEYMAP_K_DIR
		eof
	)"
}; run_with_filter test__other_keymap_kk

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

function test__other_keymap_t {
	assert "$(
		local output; output=$(other_keymap_t | bw)
		# shellcheck disable=SC2076
		[[ $output =~ 'Command executed in .0[0-9] seconds$' ]] && echo 1 || echo 2
	)" '1'
}; run_with_filter test__other_keymap_t

function test__other_keymap_t__when_sleeping {
	assert "$(
		local output; output=$(other_keymap_t sleep 0.1| bw)
		# shellcheck disable=SC2076
		[[ $output =~ 'Command executed in .1[0-9] seconds$' ]] && echo 1 || echo 2
	)" '1'
}; run_with_filter test__other_keymap_t__when_sleeping

function test__other_keymap_u {
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
		other_keymap_u <(echo "$old") <(echo "$new") | bw | sed 1,2d
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
}; run_with_filter test__other_keymap_u

function test__other_keymap_uu {
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
		other_keymap_uu <(echo "$old") <(echo "$new") | bw
	)" "$(
		cat <<-eof
			This is the original content.                                 | This is the modified content.
			                                                              > New Line
		eof
	)"
}; run_with_filter test__other_keymap_uu

function test__other_keymap_w {
	local file; file=$(
		cat <<-eof
			a,10,x1
			b,20,x2
			c,30,x3
			d,40,x4
		eof
	)

	assert "$(
		other_keymap_w <(echo "$file") 2 3
	)" "$(
		cat <<-eof
			a,x1,10
			b,x2,20
			c,x3,30
			d,x4,40
		eof
	)"
}; run_with_filter test__other_keymap_w

function test__other_keymap_w__when_specifying_only_one_column {
	local file; file=$(
		cat <<-eof
			a,10,x1
			b,20,x2
			c,30,x3
			d,40,x4
		eof
	)

	assert "$(
		other_keymap_w <(echo "$file") 2
	)" "$(
		cat <<-eof
			10,a,x1
			20,b,x2
			30,c,x3
			40,d,x4
		eof
	)"
}; run_with_filter test__other_keymap_w__when_specifying_only_one_column

function test__other_keymap_w__when_invoked_after_pipe {
	local file; file=$(
		cat <<-eof
			a,10,x1
			b,20,x2
			c,30,x3
			d,40,x4
		eof
	)

	assert "$(
		echo "$file" | other_keymap_w 2 3
	)" "$(
		cat <<-eof
			a,x1,10
			b,x2,20
			c,x3,30
			d,x4,40
		eof
	)"
}; run_with_filter test__other_keymap_w__when_invoked_after_pipe

function test__other_keymap_w__when_when_invoked_after_pipe_and_specifying_only_one_column {
	local file; file=$(
		cat <<-eof
			a,10,x1
			b,20,x2
			c,30,x3
			d,40,x4
		eof
	)

	assert "$(
		echo "$file" | other_keymap_w 2
	)" "$(
		cat <<-eof
			10,a,x1
			20,b,x2
			30,c,x3
			40,d,x4
		eof
	)"
}; run_with_filter test__other_keymap_w__when_when_invoked_after_pipe_and_specifying_only_one_column

function test__other_keymap_x {
	local file1; file1=$(
		cat <<-eof
			a,10
			b,20
			c,30
			d,40
		eof
	)

	local file2; file2=$(
		cat <<-eof
			b
			d
		eof
	)

	assert "$(
		other_keymap_x <(echo "$file1") <(echo "$file2")
	)" "$(
		cat <<-eof
			b,20
			d,40
		eof
	)"
}; run_with_filter test__other_keymap_x

function test__other_keymap_x__when_file_1_has_only_1_column {
	local file1; file1=$(
		cat <<-eof
			a
			b
			c
			d
		eof
	)

	local file2; file2=$(
		cat <<-eof
			b,20
			d,40
		eof
	)

	assert "$(
		other_keymap_x <(echo "$file1") <(echo "$file2")
	)" "$(
		cat <<-eof
			b
			d
		eof
	)"
}; run_with_filter test__other_keymap_x__when_file_1_has_only_1_column

function test__other_keymap_x__when_file_2_has_only_1_column {
	local file1; file1=$(
		cat <<-eof
			a,10
			b,20
			c,30
			d,40
		eof
	)

	local file2; file2=$(
		cat <<-eof
			b
			d
		eof
	)

	assert "$(
		other_keymap_x <(echo "$file1") <(echo "$file2")
	)" "$(
		cat <<-eof
			b,20
			d,40
		eof
	)"
}; run_with_filter test__other_keymap_x__when_file_2_has_only_1_column

function test__other_keymap_x__when_both_files_have_only_1_column {
	local file1; file1=$(
		cat <<-eof
			a
			b
			c
			d
		eof
	)

	local file2; file2=$(
		cat <<-eof
			b
			d
		eof
	)

	assert "$(
		other_keymap_x <(echo "$file1") <(echo "$file2")
	)" "$(
		cat <<-eof
			b
			d
		eof
	)"
}; run_with_filter test__other_keymap_x__when_both_files_have_only_1_column

function test__other_keymap_xx {
	local file1; file1=$(
		cat <<-eof
			a,10
			b,20
			c,30
			d,40
		eof
	)

	local file2; file2=$(
		cat <<-eof
			a
			c
		eof
	)

	assert "$(
		other_keymap_xx <(echo "$file1") <(echo "$file2")
	)" "$(
		cat <<-eof
			b,20
			d,40
		eof
	)"
}; run_with_filter test__other_keymap_xx
