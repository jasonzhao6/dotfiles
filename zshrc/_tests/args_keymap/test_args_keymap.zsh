test__input=$(
	cat <<-eof
		terraform-application-region-shared-1
		terraform-application-region-shared-2
		terraform-application-region-shared-3
		terraform-application-region-program-A
		terraform-application-region-program-B
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
}

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
}

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
}

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
}

function test__args_keymap_a__with_two_args_out_of_order {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_a 2 shared
	)" "$(
		cat <<-eof

		     1	terraform-application-region-$(grep_color shared)-$(grep_color 2)
		eof
	)"
}

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
}

function test__args_keymap_b {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_b 1 2 echo ~~ > /dev/null 2>&1
		sort "$ARGS_BACKGROUND_OUTPUTS_FILE"
	)" "$(
		cat <<-eof
			terraform-application-region-shared-1
			terraform-application-region-shared-2
		eof
	)"
}

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
}

function test__args_keymap_c__with_one_arg {
	assert "$(args_keymap_c '123'; pbpaste)" '123'
}

function test__args_keymap_c__with_two_args {
	assert "$(args_keymap_c '123 321'; pbpaste)" '123 321'
}

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
}

function test__args_keymap_e {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_e echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-program-B
			terraform-application-region-program-B
		eof
	)"
}

function test__args_keymap_f {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_f 3 4 echo 2>&1
	)" "$(
		cat <<-eof

			echo terraform-application-region-shared-3
			terraform-application-region-shared-3

			echo terraform-application-region-program-A
			terraform-application-region-program-A
		eof
	)"
}

function test__args_keymap_f__with_multiple_substitutions {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_f 3 4 echo ~~ and ~~ again 2>&1
	)" "$(
		cat <<-eof

			echo terraform-application-region-shared-3 and terraform-application-region-shared-3 again
			terraform-application-region-shared-3 and terraform-application-region-shared-3 again

			echo terraform-application-region-program-A and terraform-application-region-program-A again
			terraform-application-region-program-A and terraform-application-region-program-A again
		eof
	)"
}

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

			----------------
			Index 3
			----------------
			3
			4

			----------------
			Index 2
			----------------
			2
			3

			----------------
			Index 1
			----------------
			1
			2
		eof
	)"
}

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

			----------------
			Index 3
			----------------
			3
			4

			----------------
			Index 2
			----------------
			2
			3

			----------------
			Index 1
			----------------
			1
			2
			$(red_bar 'Index out of range: 4')
		eof
	)"
}

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
}

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
}

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
}

function test__args_keymap_hc {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_hc
		echo "$ARGS_HISTORY_INDEX/$ARGS_HISTORY_HEAD/$ARGS_HISTORY_TAIL"
	)" '100/100/-1'
}

function test__args_keymap_i {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_i
	)" "$(
		cat <<-eof

		     1	10.0.0.3	# 2023-06-21T20:24:59+00:00	foo
		     2	10.0.0.2	# 2023-06-21T21:25:00+00:00	bar
		     3	10.0.0.1	# 2023-06-21T20:25:00+00:00	baz
			$(green_bg '        a               b c                             d  ')
		eof
	)"
}

function test__args_keymap_i__when_selecting_first {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_i a
	)" "$(
		cat <<-eof

		     1	10.0.0.3
		     2	10.0.0.2
		     3	10.0.0.1
		eof
	)"
}

function test__args_keymap_i__when_selecting_third {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_i c
	)" "$(
		cat <<-eof

		     1	2023-06-21T20:24:59+00:00
		     2	2023-06-21T21:25:00+00:00
		     3	2023-06-21T20:25:00+00:00
		eof
	)"
}

function test__args_keymap_i__when_selecting_last {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_i d
	)" "$(
		cat <<-eof

		     1	foo
		     2	bar
		     3	baz
		eof
	)"
}

function test__args_keymap_i__when_selecting_with_color {
	assert "$(
		echo "$test__input_with_tabs" | grep 00 | args_keymap_s > /dev/null
		args_keymap_i d
	)" "$(
		cat <<-eof

		     1	foo
		     2	bar
		     3	baz
		eof
	)"
}

function test__args_keymap_i__when_selecting_out_of_bound {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_i z
	)" "$(red_bar "Column 'z' is out of range")"
}

function test__args_keymap_i__with_kubectl_get_pods_output {
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
		args_keymap_i e
	)" "$(
		cat <<-eof

		     1	15h
		     2	7d14h
		     3	43d
		     4	14h
		eof
	)"
}

function test__args_keymap_i__with_one_column {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_i a
	)" "$(
		cat <<-eof

		     1	terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		     5	terraform-application-region-program-B
		eof
	)"
}

function test__args_keymap_i__with_whitespace {
	assert "$(
		echo "$test__input_with_whitespace" | args_keymap_s > /dev/null
		args_keymap_i a
	)" "$(
		cat <<-eof

		     1	  terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	  terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		eof
	)"
}

function test__args_keymap_i__with_headers {
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s > /dev/null
		args_keymap_i
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
}

# Real `ls -l` right-aligns sizes, so a wider value starts left of the boundary
# the bottom row sets; slicing must not chop `13978` down to `3978`
function test__args_keymap_i__with_a_right_aligned_column {
	assert "$(
		printf '%s\n' \
			'-rw-r--r--  1 yzhao  staff  13978 Aug 22 13:26 README.md' \
			'-rw-r--r--  1 yzhao  staff   6305 Jul 20 20:51 CLAUDE.md' \
			'-rw-r--r--  1 yzhao  staff     44 Aug  6 16:11 terraformrc.txt' \
			| args_keymap_s > /dev/null
		args_keymap_i e
	)" "$(
		cat <<-eof

		     1	13978
		     2	6305
		     3	44
		eof
	)"
}

# Row 2 has nothing under column `b`, so it drops out and the rest renumber
function test__args_keymap_i__with_a_blank_column {
	assert "$(
		printf '%s\n' \
			'foo bar  30' \
			'baz      4' \
			'qux zap  200' \
			| args_keymap_s > /dev/null
		args_keymap_i b
	)" "$(
		cat <<-eof

		     1	bar
		     2	zap
		eof
	)"
}

function test__args_keymap_i__when_specifying_a_non_letter {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_i 2
	)" "$(red_bar "Column '2' is out of range")"
}

function test__args_keymap_ii {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_ii
	)" "$(
		cat <<-eof

		     1	10.0.0.3	# 2023-06-21T20:24:59+00:00	foo
		     2	10.0.0.2	# 2023-06-21T21:25:00+00:00	bar
		     3	10.0.0.1	# 2023-06-21T20:25:00+00:00	baz
			$(green_bg '        a               b c                             d  ')
		eof
	)"
}

function test__args_keymap_ii__sort_by_first_column {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_ii a
	)" "$(
		cat <<-eof

		     1	10.0.0.1	# 2023-06-21T20:25:00+00:00	baz
		     2	10.0.0.2	# 2023-06-21T21:25:00+00:00	bar
		     3	10.0.0.3	# 2023-06-21T20:24:59+00:00	foo
		eof
	)"
}

function test__args_keymap_ii__sort_by_timestamps {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_ii c
	)" "$(
		cat <<-eof

		     1	10.0.0.3	# 2023-06-21T20:24:59+00:00	foo
		     2	10.0.0.1	# 2023-06-21T20:25:00+00:00	baz
		     3	10.0.0.2	# 2023-06-21T21:25:00+00:00	bar
		eof
	)"
}

function test__args_keymap_ii__sort_by_names {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_ii d
	)" "$(
		cat <<-eof

		     1	10.0.0.2	# 2023-06-21T21:25:00+00:00	bar
		     2	10.0.0.1	# 2023-06-21T20:25:00+00:00	baz
		     3	10.0.0.3	# 2023-06-21T20:24:59+00:00	foo
		eof
	)"
}

function test__args_keymap_ii__with_space_delimited_data {
	# Simulates ls -l output with space-delimited columns
	assert "$(
		printf '%s\n' \
			'-rw-r--r-- 31 user staff 200 Aug 3 file3.txt' \
			'-rw-r--r-- 1 user staff 100 Aug 1 file1.txt' \
			'-rw-r--r-- 7 user staff 50 Aug 2 file2.txt' \
			| args_keymap_s > /dev/null
		args_keymap_ii b
	)" "$(
		cat <<-eof

		     1	-rw-r--r-- 1 user staff 100 Aug 1 file1.txt
		     2	-rw-r--r-- 7 user staff 50 Aug 2 file2.txt
		     3	-rw-r--r-- 31 user staff 200 Aug 3 file3.txt
		eof
	)"
}

function test__args_keymap_ii__with_space_delimited_sizes {
	# Sorting by file size (column 5) in ls -l style output
	assert "$(
		printf '%s\n' \
			'-rw-r--r-- 1 user staff 100 Aug 1 file1.txt' \
			'-rw-r--r-- 1 user staff 50 Aug 2 file2.txt' \
			'-rw-r--r-- 1 user staff 200 Aug 3 file3.txt' \
			| args_keymap_s > /dev/null
		args_keymap_ii e
	)" "$(
		cat <<-eof

		     1	-rw-r--r-- 1 user staff 50 Aug 2 file2.txt
		     2	-rw-r--r-- 1 user staff 100 Aug 1 file1.txt
		     3	-rw-r--r-- 1 user staff 200 Aug 3 file3.txt
		eof
	)"
}

# The `total` line from `ls -l` never reaches the size column, so its key must be
# empty rather than latching onto `88`, the last token on that line
function test__args_keymap_ii__with_a_row_too_short_to_reach_the_column {
	assert "$(
		printf '%s\n' \
			'total 88' \
			'-rw-r--r--  1 yzhao  staff  13978 Aug 22 13:26 README.md' \
			'-rw-r--r--  1 yzhao  staff     44 Aug  6 16:11 terraformrc.txt' \
			| args_keymap_s > /dev/null
		args_keymap_ii e
	)" "$(
		cat <<-eof

		     1	total 88
		     2	-rw-r--r--  1 yzhao  staff     44 Aug  6 16:11 terraformrc.txt
		     3	-rw-r--r--  1 yzhao  staff  13978 Aug 22 13:26 README.md
		eof
	)"
}

# Sorting `ls -l` by size: a truncated key would order these 44, 305, 978
function test__args_keymap_ii__with_a_right_aligned_column {
	assert "$(
		printf '%s\n' \
			'-rw-r--r--  1 yzhao  staff   6305 Jul 20 20:51 CLAUDE.md' \
			'-rw-r--r--  1 yzhao  staff  13978 Aug 22 13:26 README.md' \
			'-rw-r--r--  1 yzhao  staff     44 Aug  6 16:11 terraformrc.txt' \
			| args_keymap_s > /dev/null
		args_keymap_ii e
	)" "$(
		cat <<-eof

		     1	-rw-r--r--  1 yzhao  staff     44 Aug  6 16:11 terraformrc.txt
		     2	-rw-r--r--  1 yzhao  staff   6305 Jul 20 20:51 CLAUDE.md
		     3	-rw-r--r--  1 yzhao  staff  13978 Aug 22 13:26 README.md
		eof
	)"
}

# Row 2 has nothing under column `b`, so keying on whitespace-delimited fields
# would shift its `c` value into `b` and sort the row into the wrong place
function test__args_keymap_ii__with_a_blank_column {
	assert "$(
		printf '%s\n' \
			'foo bar  30' \
			'baz      4' \
			'qux zap  200' \
			| args_keymap_s > /dev/null
		args_keymap_ii c
	)" "$(
		cat <<-eof

		     1	baz      4
		     2	foo bar  30
		     3	qux zap  200
		eof
	)"
}

# `z` is past the last column, so it must not fall back to keying on the whole row
function test__args_keymap_ii__when_sorting_out_of_bound {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_ii z
	)" "$(red_bar "Column 'z' is out of range")"
}

function test__args_keymap_ii__when_specifying_a_non_letter {
	assert "$(
		echo "$test__input_with_tabs" | args_keymap_s > /dev/null
		args_keymap_ii 2
	)" "$(red_bar "Column '2' is out of range")"
}

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
}

function test__args_keymap_n__populates_empty_args_for_n {
	# In a fresh shell with no args yet, `<number> n` acts on the cwd listing
	assert "$(
		rm -rf /tmp/test__args_keymap_n
		mkdir /tmp/test__args_keymap_n
		cd /tmp/test__args_keymap_n || return
		echo 'one' > 1.txt
		echo 'two' > 2.txt
		args_history_reset
		args_keymap_n 2 n | bw | grep --count '^2.txt$'
		cd /tmp && rm -rf /tmp/test__args_keymap_n
	)" '1'
}

function test__args_keymap_n__populates_empty_args_for_cat {
	assert "$(
		rm -rf /tmp/test__args_keymap_n
		mkdir /tmp/test__args_keymap_n
		cd /tmp/test__args_keymap_n || return
		echo 'one' > 1.txt
		echo 'two' > 2.txt
		args_history_reset
		args_keymap_n 2 cat | bw | grep --count '^two$'
		cd /tmp && rm -rf /tmp/test__args_keymap_n
	)" '1'
}

function test__args_keymap_n__does_not_populate_empty_args_for_other_commands {
	assert "$(
		rm -rf /tmp/test__args_keymap_n
		mkdir /tmp/test__args_keymap_n
		cd /tmp/test__args_keymap_n || return
		echo 'one' > 1.txt
		args_history_reset
		args_keymap_n 1 echo > /dev/null
		args_helpers_size | strip
		cd /tmp && rm -rf /tmp/test__args_keymap_n
	)" '0'
}

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
}

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
}

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
}

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
}

function test__args_keymap_n__cd_into_folder_with_spaces {
	mkdir -p '/tmp/test folder with spaces'
	assert "$(
		echo '/tmp/test folder with spaces' | args_keymap_s > /dev/null
		args_keymap_n 1 cd 2>&1 && pwd
	)" "$(
		cat <<-eof
			cd "/tmp/test folder with spaces"
			/tmp/test folder with spaces
		eof
	)"
	rm -rf '/tmp/test folder with spaces'
}

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
}

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
}

function test__args_keymap_r {
	assert "$(
		seq 3 | args_keymap_s > /dev/null
		args_keymap_r
	)" "$(
		cat <<-eof

		     1	3
		     2	2
		     3	1
		eof
	)"
}

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
}

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
}

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
}

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
}

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
}

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
}

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
}

function test__args_keymap_u__when_undoing_empty_history {
	assert "$(
		args_keymap_hc
		args_keymap_u
	)" "$(
		cat <<-eof
			$(red_bar 'Reached the end of undo history')
		eof
	)"
}

function test__args_keymap_u__when_undoing_i_with_headers {
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s > /dev/null
		args_keymap_i a > /dev/null
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
}

function test__args_keymap_u__when_undoing_ii_with_headers {
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s > /dev/null
		args_keymap_ii a > /dev/null
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
}

function test__args_keymap_u__when_undoing_d_with_headers {
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s > /dev/null
		args_keymap_d > /dev/null
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
}

function test__args_keymap_u__when_undoing_t_with_headers {
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s > /dev/null
		args_keymap_t > /dev/null
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
}

function test__args_keymap_u__when_undoing_i_then_requesting_columns_bar {
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s > /dev/null
		args_keymap_i a > /dev/null
		args_keymap_u > /dev/null
		args_keymap_i
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
}

function test__args_keymap_u__when_undoing_ss_that_could_look_like_nn {
	assert "$(
		echo "$test__input_with_headers" | args_keymap_s > /dev/null
		args_keymap_ii > /dev/null
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
}

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
}

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
}

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
}

function test__args_keymap_u__when_undoing_then_redoing_with_color {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_a program > /dev/null
		args_keymap_u > /dev/null
		args_keymap_uu
	)" "$(
		cat <<-eof

		     1	terraform-application-region-$(grep_color program)-A
		     2	terraform-application-region-$(grep_color program)-B
		eof
	)"
}

function test__args_keymap_u__when_undoing_then_redoing_then_undoing_again_with_color {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		args_keymap_a program > /dev/null
		args_keymap_u > /dev/null
		args_keymap_a terraform > /dev/null
		args_keymap_a application > /dev/null
		args_keymap_uu > /dev/null
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
}

function test__args_keymap_uu__when_undoing_empty_history {
	assert "$(
		args_keymap_hc
		args_keymap_uu
	)" "$(
		cat <<-eof
			$(red_bar 'Reached the end of redo history')
		eof
	)"
}

function test__args_keymap_uu__when_redoing_x2 {
	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		args_keymap_u > /dev/null
		args_keymap_u > /dev/null
		args_keymap_uu > /dev/null
		args_keymap_uu
	)" "$(
		cat <<-eof

		     1	3
		     2	4
		eof
	)"
}

function test__args_keymap_uu__when_redoing_beyond_head {
	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		args_keymap_u > /dev/null
		args_keymap_u > /dev/null
		args_keymap_uu > /dev/null
		args_keymap_uu > /dev/null
		args_keymap_uu
	)" "$(
		cat <<-eof

		     1	3
		     2	4
			$(red_bar 'Reached the end of redo history')
		eof
	)"
}

function test__args_keymap_uu__when_redoing_beyond_new_head {
	assert "$(
		seq 1 2 | args_keymap_s > /dev/null
		seq 2 3 | args_keymap_s > /dev/null
		seq 3 4 | args_keymap_s > /dev/null
		args_keymap_u > /dev/null
		args_keymap_u > /dev/null
		seq 4 5 | args_keymap_s > /dev/null
		args_keymap_uu
	)" "$(
		cat <<-eof

		     1	4
		     2	5
			$(red_bar 'Reached the end of redo history')
		eof
	)"
}

function test__args_keymap_y {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		rm -f "$ARGS_YANK_FILE"
		args_keymap_y
		cat "$ARGS_YANK_FILE"
	)" "$test__input"
}
