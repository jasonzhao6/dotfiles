test__input=$(
	cat <<-eof
		terraform-application-region-shared-1
		terraform-application-region-shared-2
		terraform-application-region-shared-3
		terraform-application-region-program-A
		terraform-application-region-program-B
	eof
)

test__input_short=$(
	cat <<-eof
		terraform-application-region-shared-1
		terraform-application-region-shared-2
	eof
)

test__input_with_whitespace=$(
	cat <<-eof
		  terraform-application-region-shared-1
		terraform-application-region-shared-2
		  terraform-application-region-shared-3
		terraform-application-region-program-A
	eof
)

test__input_with_headers=$(
	cat <<-eof
		MANIFEST                                COMMENT
		terraform-application-region-shared-1   hello world
		terraform-application-region-shared-2   foo bar
		terraform-application-region-shared-3   sup
		terraform-application-region-program-A  how are you
		terraform-application-region-program-B  select via headers for this one
	eof
)

test__input_with_headers_top_heavy=$(
	cat <<-eof
		MANIFEST                                COMMENT
		terraform-application-region-shared-1   hello world
		terraform-application-region-shared-2
		terraform-application-region-shared-3
		terraform-application-region-program-A
		terraform-application-region-program-B
	eof
)

test__input_with_tabs=$(
	cat <<-eof
		10.0.0.3	# 2023-06-21T20:24:59+00:00	foo
		10.0.0.2	# 2023-06-21T21:25:00+00:00	bar
		10.0.0.1	# 2023-06-21T20:25:00+00:00	baz
	eof
)

function test__args_keymap {
	assert "$(
		local show_this_help; show_this_help=$(args_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $ARGS_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}; run_with_filter test__args_keymap

function test__args_keymap_- {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_- 3 4 echo 2>&1
	)" "$(
		cat <<-eof

			echo terraform-application-region-shared-3
			terraform-application-region-shared-3

			echo terraform-application-region-program-A
			terraform-application-region-program-A
		eof
	)"
}; run_with_filter test__args_keymap_-

function test__args_keymap_-__with_multiple_substitutions {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_- 3 4 echo ~~ and ~~ again 2>&1
	)" "$(
		cat <<-eof

			echo terraform-application-region-shared-3 and terraform-application-region-shared-3 again
			terraform-application-region-shared-3 and terraform-application-region-shared-3 again

			echo terraform-application-region-program-A and terraform-application-region-program-A again
			terraform-application-region-program-A and terraform-application-region-program-A again
		eof
	)"
}; run_with_filter test__args_keymap_-__with_multiple_substitutions

function test__args_keymap_a {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_a
	)" "$(
		cat <<-eof
		     1	terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		     5	terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__args_keymap_a

function test__args_keymap_a__adds_color {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_a shared
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep_color shared)-1
		     2	terraform-application-region-$(grep_color shared)-2
		     3	terraform-application-region-$(grep_color shared)-3
		eof
	)"
}; run_with_filter test__args_keymap_a__adds_color

function test__args_keymap_a__replaces_color {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_a shared > /dev/null
		args_keymap_a region
	)" "$(
		cat <<-eof
		     1	terraform-application-$(grep_color region)-shared-1
		     2	terraform-application-$(grep_color region)-shared-2
		     3	terraform-application-$(grep_color region)-shared-3
		eof
	)"
}; run_with_filter test__args_keymap_a__replaces_color

function test__args_keymap_a__with_two_args_out_of_order {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_a 2 shared
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep_color shared)-$(grep_color 2)
		eof
	)"
}; run_with_filter test__args_keymap_a__with_two_args_out_of_order

function test__args_keymap_a__with_two_args_including_negation {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_a -2 shared
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep_color shared)-1
		     2	terraform-application-region-$(grep_color shared)-3
		eof
	)"
}; run_with_filter test__args_keymap_a__with_two_args_including_negation

function test__args_keymap_c {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_c
		pbpaste
	)" "$(
		cat <<-eof
			terraform-application-region-shared-1
			terraform-application-region-shared-2
			terraform-application-region-shared-3
			terraform-application-region-program-A
			terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__args_keymap_c

function test__args_keymap_c__with_one_arg {
	assert "$(args_keymap_c '123'; pbpaste)" '123'
}; run_with_filter test__args_keymap_c__with_one_arg

function test__args_keymap_c__with_two_args {
	assert "$(args_keymap_c '123 321'; pbpaste)" '123 321'
}; run_with_filter test__args_keymap_c__with_two_args

function test__args_keymap_d {
	local input; input=$(
		cat <<-eof
			Succeeded
			Failed
			Succeeded
			Failed
			Failed
		eof
	)
	assert "$(
		echo "$input" | args_keymap_s > /dev/null
		args_keymap_d
	)" "$(
		cat <<-eof
	     1	Failed
	     2	Succeeded
		eof
	)"
}; run_with_filter test__args_keymap_d

function test__args_keymap_e {
	assert "$(
		echo "$test__input_short" | args_keymap_s > /dev/null
		other_keymap_- 1 $(($(args_size) * 4)) args_keymap_e echo 2>&1 | sort --unique
	)" "$(
		cat <<-eof

			args_keymap_e echo
			echo terraform-application-region-shared-1
			echo terraform-application-region-shared-2
			terraform-application-region-shared-1
			terraform-application-region-shared-2
		eof
	)"
}; run_with_filter test__args_keymap_e

function test__args_keymap_h {
	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		args_keymap_h
	)" "$(
		cat <<-eof
			index: 3
			head: 3
			tail: 1
			max: 100

			----------------------------------------
			Index 3
			----------------------------------------
			3
			4

			----------------------------------------
			Index 2
			----------------------------------------
			2
			3

			----------------------------------------
			Index 1
			----------------------------------------
			1
			2
		eof
	)"
}; run_with_filter test__args_keymap_h

function test__args_keymap_h__when_selecting_out_of_head_and_tail {
	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		args_keymap_h 4
	)" "$(
		cat <<-eof
			index: 3
			head: 3
			tail: 1
			max: 100

			----------------------------------------
			Index 3
			----------------------------------------
			3
			4

			----------------------------------------
			Index 2
			----------------------------------------
			2
			3

			----------------------------------------
			Index 1
			----------------------------------------
			1
			2

			$(red_bar 'Index out of range: 4')
		eof
	)"
}; run_with_filter test__args_keymap_h__when_selecting_out_of_head_and_tail

function test__args_keymap_h__when_selecting_head_index {
	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		args_keymap_h 3
	)" "$(
		cat <<-eof
		     1	3
		     2	4
		eof
	)"
}; run_with_filter test__args_keymap_h__when_selecting_head_index

function test__args_keymap_h__when_selecting_middle_index {
	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		args_keymap_h 2
	)" "$(
		cat <<-eof
		     1	2
		     2	3
		eof
	)"
}; run_with_filter test__args_keymap_h__when_selecting_middle_index

function test__args_keymap_h__when_selecting_tail_index {
	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		args_keymap_h 1
	)" "$(
		cat <<-eof
		     1	1
		     2	2
		eof
	)"
}; run_with_filter test__args_keymap_h__when_selecting_tail_index

function test__args_keymap_i {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_i
	)" "$(
		cat <<-eof
		     1	10.0.0.1	# 2023-06-21T20:25:00+00:00	baz
		     2	10.0.0.2	# 2023-06-21T21:25:00+00:00	bar
		     3	10.0.0.3	# 2023-06-21T20:24:59+00:00	foo
		eof
	)"
}; run_with_filter test__args_keymap_i

function test__args_keymap_i__with_timestamps {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_i 3
	)" "$(
		cat <<-eof
		     1	10.0.0.3	# 2023-06-21T20:24:59+00:00	foo
		     2	10.0.0.1	# 2023-06-21T20:25:00+00:00	baz
		     3	10.0.0.2	# 2023-06-21T21:25:00+00:00	bar
		eof
	)"
}; run_with_filter test__args_keymap_i__with_timestamps

function test__args_keymap_i__with_names {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_i 4
	)" "$(
		cat <<-eof
		     1	10.0.0.2	# 2023-06-21T21:25:00+00:00	bar
		     2	10.0.0.1	# 2023-06-21T20:25:00+00:00	baz
		     3	10.0.0.3	# 2023-06-21T20:24:59+00:00	foo
		eof
	)"
}; run_with_filter test__args_keymap_i__with_names

function test__args_keymap_n {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_n 3 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-shared-3
			terraform-application-region-shared-3
		eof
	)"
}; run_with_filter test__args_keymap_n

function test__args_keymap_n__with_whitespace {
	assert "$(
		echo "$test__input_with_whitespace" | args_keymap_s > /dev/null
		args_keymap_n 3 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-shared-3
			terraform-application-region-shared-3
		eof
	)"
}; run_with_filter test__args_keymap_n__with_whitespace

function test__args_keymap_n__with_substitution {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_n 3 echo http://~~:8080 2>&1
	)" "$(
		cat <<-eof
			echo http://terraform-application-region-shared-3:8080
			http://terraform-application-region-shared-3:8080
		eof
	)"
}; run_with_filter test__args_keymap_n__with_substitution

function test__args_keymap_n__with_multiple_substitutions {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_n 3 echo http://~~:80 and https://~~:443 2>&1
	)" "$(
		cat <<-eof
			echo http://terraform-application-region-shared-3:80 and https://terraform-application-region-shared-3:443
			http://terraform-application-region-shared-3:80 and https://terraform-application-region-shared-3:443
		eof
	)"
}; run_with_filter test__args_keymap_n__with_multiple_substitutions

function test__args_keymap_n__with_multiple_substitutions_in_quotes {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_n 3 'echo http://~~:80 and https://~~:443' 2>&1
	)" "$(
		cat <<-eof
			echo http://terraform-application-region-shared-3:80 and https://terraform-application-region-shared-3:443
			http://terraform-application-region-shared-3:80 and https://terraform-application-region-shared-3:443
		eof
	)"
}; run_with_filter test__args_keymap_n__with_multiple_substitutions_in_quotes

function test__args_keymap_o {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_o echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-shared-1
			terraform-application-region-shared-1
		eof
	)"
}; run_with_filter test__args_keymap_o

function test__args_keymap_p {
	assert "$(
		seq 3 > "$ARGS_YANK_FILE"
		args_keymap_p
	)" "$(
		cat <<-eof
		     1	1
		     2	2
		     3	3
		eof
	)"
}; run_with_filter test__args_keymap_p

function test__args_keymap_r__when_undoing_empty_history {
	assert "$(
		args_keymap_hc
		args_keymap_r
	)" "$(
		cat <<-eof

			$(red_bar 'Reached the end of redo history')
		eof
	)"
}; run_with_filter test__args_keymap_r__when_undoing_empty_history

function test__args_keymap_r__when_redoing_x2 {
	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		args_keymap_u > /dev/null
		args_keymap_u > /dev/null
		args_keymap_r > /dev/null
		args_keymap_r
	)" "$(
		cat <<-eof
		     1	3
		     2	4
		eof
	)"
}; run_with_filter test__args_keymap_r__when_redoing_x2

function test__args_keymap_r__when_redoing_beyond_head {
	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		args_keymap_u > /dev/null
		args_keymap_u > /dev/null
		args_keymap_r > /dev/null
		args_keymap_r > /dev/null
		args_keymap_r
	)" "$(
		cat <<-eof
		     1	3
		     2	4
			$(red_bar 'Reached the end of redo history')
		eof
	)"
}; run_with_filter test__args_keymap_r__when_redoing_beyond_head

function test__args_keymap_r__when_redoing_beyond_new_head {
	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		args_keymap_u > /dev/null
		args_keymap_u > /dev/null
		seq 4 5 | args_keymap_s > /dev/null
		args_keymap_r
	)" "$(
		cat <<-eof
		     1	4
		     2	5
			$(red_bar 'Reached the end of redo history')
		eof
	)"
}; run_with_filter test__args_keymap_r__when_redoing_beyond_new_head

function test__args_keymap_s {
	# Can test `[command] | args_keymap_s`, but not `[command]; as`
	# The latter requires an interactive shell
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
		eof
	)"
}; run_with_filter test__args_keymap_s

function test__args_keymap_s__with_filters {
	# Can test `[command] | args_keymap_s`, but not `[command]; as`
	# The latter requires an interactive shell
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s -1 shared
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep_color shared)-2   foo bar
		     2	terraform-application-region-$(grep_color shared)-3   sup
		eof
	)"
}; run_with_filter test__args_keymap_s__with_filters

function test__args_keymap_s__with_whitespace {
	# Can test `[command] | args_keymap_s`, but not `[command]; as`
	# The latter requires an interactive shell
	assert "$(
		echo "$test__input_with_whitespace" | args_keymap_s
	)" "$(
		cat <<-eof
		     1	  terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	  terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		eof
	)"
}; run_with_filter test__args_keymap_s__with_whitespace

function test__args_keymap_so {
	# Can test `<command> | args_keymap_so`, but not `<command>; aso`
	# The latter requires an interactive shell.
	assert "$(
		echo "$test__input_with_headers" | args_keymap_so
	)" "$(
		cat <<-eof
		     1	MANIFEST                                # COMMENT
		     2	terraform-application-region-shared-1   # hello world
		     3	terraform-application-region-shared-2   # foo bar
		     4	terraform-application-region-shared-3   # sup
		     5	terraform-application-region-program-A  # how are you
		     6	terraform-application-region-program-B  # select via headers for this one
		eof
	)"
}; run_with_filter test__args_keymap_so

function test__args_keymap_so__with_filters {
	# Can test `<command> | args_keymap_so`, but not `<command>; aso`
	# The latter requires an interactive shell.
	assert "$(
		echo "$test__input_with_headers" | args_keymap_so -1 shared
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep_color shared)-2   # foo bar
		     2	terraform-application-region-$(grep_color shared)-3   # sup
		eof
	)"
}; run_with_filter test__args_keymap_so__with_filters

function test__args_keymap_t {
	local input; input=$(
		cat <<-eof
			aa-us-east-1	Succeeded	2025-01-16T15:15:40.292000-08:00
			bb-us-east-1	Failed	2025-01-16T15:14:38.132000-08:00
			cc-us-east-1	Failed	2025-01-16T15:14:34.400000-08:00
		eof
	)
	assert "$(
		echo "$input" | args_keymap_s > /dev/null
		args_keymap_t
	)" "$(
		cat <<-eof
	     1	aa-us-east-1  Succeeded  2025-01-16T15:15:40.292000-08:00
	     2	bb-us-east-1  Failed     2025-01-16T15:14:38.132000-08:00
	     3	cc-us-east-1  Failed     2025-01-16T15:14:34.400000-08:00
		eof
	)"
}; run_with_filter test__args_keymap_t

function test__args_keymap_u {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_a program > /dev/null
		args_keymap_u
	)" "$(
		cat <<-eof
		     1	terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		     5	terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__args_keymap_u

function test__args_keymap_u__when_undoing_empty_history {
	assert "$(
		args_keymap_hc
		args_keymap_u
	)" "$(
		cat <<-eof

			$(red_bar 'Reached the end of undo history')
		eof
	)"
}; run_with_filter test__args_keymap_u__when_undoing_empty_history

function test__args_keymap_u__when_undoing_d_with_headers {
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s > /dev/null
		args_keymap_v a > /dev/null
		args_keymap_u
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
			$(green_bg '        a                                       b      c   d       e   f    g  ')
		eof
	)"
}; run_with_filter test__args_keymap_u__when_undoing_d_with_headers

function test__args_keymap_u__when_undoing_t_with_headers {
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s > /dev/null
		args_keymap_w a > /dev/null
		args_keymap_u
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
			$(green_bg '        a                                       b      ')
		eof
	)"
}; run_with_filter test__args_keymap_u__when_undoing_t_with_headers

function test__args_keymap_u__when_undoing_t_then_requesting_n {
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s > /dev/null
		args_keymap_w a > /dev/null
		args_keymap_u > /dev/null
		args_keymap_v
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
			$(green_bg '        a                                       b      c   d       e   f    g  ')
		eof
	)"
}; run_with_filter test__args_keymap_u__when_undoing_t_then_requesting_n

function test__args_keymap_u__when_undoing_t_with_headers_top_heavy {
	assert "$(
		echo "$test__input_with_headers_top_heavy" | args_keymap_s > /dev/null
		args_keymap_w a > /dev/null
		args_keymap_u
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2
		     4	terraform-application-region-shared-3
		     5	terraform-application-region-program-A
		     6	terraform-application-region-program-B
			$(green_bg '        a                                       b      ')
		eof
	)"
}; run_with_filter test__args_keymap_u__when_undoing_t_with_headers_top_heavy

function test__args_keymap_u__when_undoing_ss_that_could_look_like_nn {
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s > /dev/null
		args_keymap_w > /dev/null
		echo "$test__input_with_headers_top_heavy" | args_keymap_s > /dev/null
		args_keymap_u
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
		eof
	)"
}; run_with_filter test__args_keymap_u__when_undoing_ss_that_could_look_like_nn

function test__args_keymap_u__when_undoing_x2 {
	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		args_keymap_u > /dev/null
		args_keymap_u
	)" "$(
		cat <<-eof
		     1	1
		     2	2
		eof
	)"
}; run_with_filter test__args_keymap_u__when_undoing_x2

function test__args_keymap_u__when_undoing_beyond_tail {
	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		args_keymap_u > /dev/null
		args_keymap_u > /dev/null
		args_keymap_u
	)" "$(
		cat <<-eof
		     1	1
		     2	2
			$(red_bar 'Reached the end of undo history')
		eof
	)"
}; run_with_filter test__args_keymap_u__when_undoing_beyond_tail

function test__args_keymap_u__when_pushing_beyond_head_then_undoing_beyond_tail {
	# shellcheck disable=SC2034
	ARGS_HISTORY_MAX=3

	args_history_init

	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		seq 4 5 | args_keymap_s > /dev/null
		args_keymap_u > /dev/null
		args_keymap_u > /dev/null
		args_keymap_u
	)" "$(
		cat <<-eof
		     1	2
		     2	3
			$(red_bar 'Reached the end of undo history')
		eof
	)"

	args_history_reset
}; run_with_filter test__args_keymap_u__when_pushing_beyond_head_then_undoing_beyond_tail

function test__args_keymap_u__when_undoing_then_redoing_with_color {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_a program > /dev/null
		args_keymap_u > /dev/null
		args_keymap_r
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep_color program)-A
		     2	terraform-application-region-$(grep_color program)-B
		eof
	)"
}; run_with_filter test__args_keymap_u__when_undoing_then_redoing_with_color

function test__args_keymap_u__when_undoing_then_redoing_then_undoing_again_with_color {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_a program > /dev/null
		args_keymap_u > /dev/null
		args_keymap_a terraform > /dev/null
		args_keymap_a application > /dev/null
		args_keymap_r > /dev/null
		args_keymap_u
	)" "$(
		cat <<-eof
		     1	terraform-$(grep_color application)-region-shared-1
		     2	terraform-$(grep_color application)-region-shared-2
		     3	terraform-$(grep_color application)-region-shared-3
		     4	terraform-$(grep_color application)-region-program-A
		     5	terraform-$(grep_color application)-region-program-B
		eof
	)"
}; run_with_filter test__args_keymap_u__when_undoing_then_redoing_then_undoing_again_with_color

function test__args_keymap_v {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_v
	)" "$(
		cat <<-eof
		     1	10.0.0.3	# 2023-06-21T20:24:59+00:00	foo
		     2	10.0.0.2	# 2023-06-21T21:25:00+00:00	bar
		     3	10.0.0.1	# 2023-06-21T20:25:00+00:00	baz
			$(green_bg '        a               b c                             d  ')
		eof
	)"
}; run_with_filter test__args_keymap_v

function test__args_keymap_v__when_selecting_first {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_v a
	)" "$(
		cat <<-eof
		     1	10.0.0.3
		     2	10.0.0.2
		     3	10.0.0.1
		eof
	)"
}; run_with_filter test__args_keymap_v__when_selecting_first

function test__args_keymap_v__when_selecting_third {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_v c
	)" "$(
		cat <<-eof
		     1	2023-06-21T20:24:59+00:00
		     2	2023-06-21T21:25:00+00:00
		     3	2023-06-21T20:25:00+00:00
		eof
	)"
}; run_with_filter test__args_keymap_v__when_selecting_third

function test__args_keymap_v__when_selecting_last {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_v d
	)" "$(
		cat <<-eof
		     1	foo
		     2	bar
		     3	baz
		eof
	)"
}; run_with_filter test__args_keymap_v__when_selecting_last

function test__args_keymap_v__when_selecting_with_color {
	assert "$(
		echo "$test__input_with_tabs" | grep 00 | args_keymap_s > /dev/null
		args_keymap_v d
	)" "$(
		cat <<-eof
		     1	foo
		     2	bar
		     3	baz
		eof
	)"
}; run_with_filter test__args_keymap_v__when_selecting_with_color

function test__args_keymap_v__when_selecting_out_of_bound {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_v z
	)" "$(
		cat <<-eof
		     1	10.0.0.3        # 2023-06-21T20:24:59+00:00     foo
		     2	10.0.0.2        # 2023-06-21T21:25:00+00:00     bar
		     3	10.0.0.1        # 2023-06-21T20:25:00+00:00     baz
			$(green_bg '        a               b c                             d  ')
		eof
	)"
}; run_with_filter test__args_keymap_v__when_selecting_out_of_bound

function test__args_keymap_v__with_kubectl_get_pods_output {
	local input; input=$(
		cat <<-eof
			pod-1           1/1     Running     1 (15h ago)        15h
			pod-2           1/1     Running     0                  7d14h
			pod-3           1/1     Running     312 (8d ago)       43d
			pod-4           1/1     Running     0                  14h
		eof
	)

	assert "$(
		echo "$input" | args_keymap_s > /dev/null
		args_keymap_v e
	)" "$(
		cat <<-eof
		     1	15h
		     2	7d14h
		     3	43d
		     4	14h
		eof
	)"
}; run_with_filter test__args_keymap_v__with_kubectl_get_pods_output

function test__args_keymap_v__with_one_column {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_v a
	)" "$(
		cat <<-eof
		     1	terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		     5	terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__args_keymap_v__with_one_column

function test__args_keymap_v__with_whitespace {
	assert "$(
		echo "$test__input_with_whitespace" | args_keymap_s > /dev/null
		args_keymap_v a
	)" "$(
		cat <<-eof
		     1	  terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	  terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		eof
	)"
}; run_with_filter test__args_keymap_v__with_whitespace

function test__args_keymap_v__with_headers {
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s > /dev/null
		args_keymap_v
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
			$(green_bg '        a                                       b      c   d       e   f    g  ')
		eof
	)"
}; run_with_filter test__args_keymap_v__with_headers

function test__args_keymap_w {
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s > /dev/null
		args_keymap_w
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
			$(green_bg '        a                                       b      ')
		eof
	)"
}; run_with_filter test__args_keymap_w

function test__args_keymap_w__with_one_column {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_w a
	)" "$(
		cat <<-eof
		     1	terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		     5	terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__args_keymap_w__with_one_column

function test__args_keymap_y {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		rm -f "$ARGS_YANK_FILE"
		args_keymap_y
		cat "$ARGS_YANK_FILE"
	)" "$test__input"
}; run_with_filter test__args_keymap_y

function test__args_keymap_z {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_z
	)" "$(
		cat <<-eof
		     1	foo
		     2	bar
		     3	baz
		eof
	)"
}; run_with_filter test__args_keymap_z
