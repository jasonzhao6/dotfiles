function test__other_keymap {
	assert "$(
		local show_this_help; show_this_help=$(other_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $OTHER_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__other_keymap_0 {
	assert "$(
		echo 'content1' > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1"
		echo 'content2' > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2"
		other_keymap_0
		local size1; size1=$(wc -c < "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1" | tr -d ' ')
		local size2; size2=$(wc -c < "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2" | tr -d ' ')
		echo "$size1/$size2"
	)" '0/0'
}

function test__other_keymap_b {
	assert "$(
		other_keymap_b 3 4 echo ~~ > /dev/null 2>&1
		sort "$OTHER_BACKGROUND_OUTPUTS_FILE"
	)" "$(
		cat <<-eof
			3
			4
		eof
	)"
}

function test__other_keymap_d {	assert "$(
		other_keymap_d www.google.com
	)" "$(
		cat <<-eof

		     1	test output for
		     2	www.google.com
		eof
	)"
}

function test__other_keymap_d__with_pasteboard {
	echo -n 'https://www.google.com' | pbcopy
	assert "$(other_keymap_d)" "$(
		cat <<-eof

		     1	test output for
		     2	www.google.com
		eof
	)"
}

function test__other_keymap_d__with_protocol {
	assert "$(
		other_keymap_d https://www.google.com
	)" "$(
		cat <<-eof

		     1	test output for
		     2	www.google.com
		eof
	)"
}

function test__other_keymap_d__with_protocol_and_path {
	assert "$(
		other_keymap_d https://www.google.com/path/to/page
	)" "$(
		cat <<-eof

		     1	test output for
		     2	www.google.com
		eof
	)"
}

function test__other_keymap_f {	assert "$(
		other_keymap_f 3 4 echo ~~ 2>&1
	)" "$(
		cat <<-eof

			echo 3
			3

			echo 4
			4
		eof
	)"
}

function test__other_keymap_f__with_multiple_substitutions {
	assert "$(
		other_keymap_f 3 4 echo ~~ and ~~ again 2>&1
	)" "$(
		cat <<-eof

			echo 3 and 3 again
			3 and 3 again

			echo 4 and 4 again
			4 and 4 again
		eof
	)"
}

function test__other_keymap_f__with_multiple_substitutions_in_quotes {
	assert "$(
		other_keymap_f 3 4 'echo ~~ and ~~ again' 2>&1
	)" "$(
		cat <<-eof

			echo 3 and 3 again
			3 and 3 again

			echo 4 and 4 again
			4 and 4 again
		eof
	)"
}

function test__other_keymap_f__with_math {
	assert "$(
		other_keymap_f 3 4 echo ~~ and '$((~~ + 10))' too 2>&1
	)" "$(
		cat <<-eof

			echo 3 and \$((3 + 10)) too
			3 and 13 too

			echo 4 and \$((4 + 10)) too
			4 and 14 too
		eof
	)"
}

function test__other_keymap_i {
	assert "$(
		printf 'a,10,x1\nb,20,x2\n' | other_keymap_i 2
	)" "$(
		cat <<-eof

			10
			20
		eof
	)"
}

function test__other_keymap_i__when_no_column_index {
	assert "$(
		printf 'a,10,x1\n' | other_keymap_i
	)" "$(
		red_bar 'Usage: oi <index> <file>?'
	)"
}

function test__other_keymap_i__with_a_file {
	local csv='/tmp/test__other_keymap_i__with_a_file.csv'
	printf 'a,10,x1\nb,20,x2\n' > $csv

	assert "$(
		other_keymap_i 3 $csv
	)" "$(
		cat <<-eof

			x1
			x2
		eof
	)"

	rm $csv
}

function test__other_keymap_i__with_an_invalid_file {
	assert "$(
		# Stubbed so a broken guard fails here, as `mlr` hangs on a dir
		function other_helpers_mlr { echo 'mlr was reached'; }

		for file in /tmp/test__other_keymap__no_such.csv /tmp; do
			printf 'a,10,x1\n' | other_keymap_i 2 "$file"
		done
	)" "$(
		red_bar 'Invalid file: /tmp/test__other_keymap__no_such.csv'
		red_bar 'Invalid file: /tmp'
	)"
}

# `awk -F,` counted 4 columns here and kept ` baz"` as the 1st
function test__other_keymap_i__with_a_quoted_cell {
	assert "$(
		printf '"bar, baz",22,note\n' | other_keymap_i 1
	)" "$(
		cat <<-eof

			"bar, baz"
		eof
	)"
}

function test__other_keymap_id {
	local file; file=$(
		cat <<-eof
			a,10,x1
			b,20,x2
			c,30,x3
		eof
	)

	assert "$(
		echo "$file" | other_keymap_id 2
	)" "$(
		cat <<-eof

			a,x1
			b,x2
			c,x3
		eof
	)"
}

function test__other_keymap_id__drop_first_column {
	local file; file=$(
		cat <<-eof
			a,10,x1
			b,20,x2
			c,30,x3
		eof
	)

	assert "$(
		echo "$file" | other_keymap_id 1
	)" "$(
		cat <<-eof

			10,x1
			20,x2
			30,x3
		eof
	)"
}

function test__other_keymap_id__drop_last_column {
	local file; file=$(
		cat <<-eof
			a,10,x1
			b,20,x2
			c,30,x3
		eof
	)

	assert "$(
		echo "$file" | other_keymap_id 3
	)" "$(
		cat <<-eof

			a,10
			b,20
			c,30
		eof
	)"
}

function test__other_keymap_id__with_windows_line_endings {
	assert "$(
		printf 'a,10,x1\r\nb,20,x2\r\n' | other_keymap_id 2
	)" "$(
		cat <<-eof

			a,x1
			b,x2
		eof
	)"
}

function test__other_keymap_id__when_no_column_index {
	assert "$(
		printf 'a,10,x1\n' | other_keymap_id
	)" "$(
		red_bar 'Usage: oid <index> <file>?'
	)"
}

function test__other_keymap_id__with_an_invalid_column_index {
	assert "$(
		for column_index in 0 -1 abc 2.5 1,2; do
			printf 'a,10,x1\n' | other_keymap_id "$column_index"
		done
	)" "$(
		for _ in $(seq 5); do
			red_bar 'Usage: oid <index> <file>?'
		done
	)"
}

function test__other_keymap_id__with_a_file {
	local csv='/tmp/test__other_keymap_id__with_a_file.csv'
	printf 'a,10,x1\nb,20,x2\n' > $csv

	assert "$(
		other_keymap_id 2 $csv
	)" "$(
		cat <<-eof

			a,x1
			b,x2
		eof
	)"

	rm $csv
}

function test__other_keymap_id__with_an_invalid_file {
	assert "$(
		# Stubbed so a broken guard fails here, as `mlr` hangs on a dir
		function other_helpers_mlr { echo 'mlr was reached'; }

		for file in /tmp/test__other_keymap__no_such.csv /tmp; do
			printf 'a,10,x1\n' | other_keymap_id 2 "$file"
		done
	)" "$(
		red_bar 'Invalid file: /tmp/test__other_keymap__no_such.csv'
		red_bar 'Invalid file: /tmp'
	)"
}

# `awk -F,` counted 4 columns here and dropped `22`, the one meant to be kept
function test__other_keymap_id__with_a_quoted_cell {
	assert "$(
		printf '"bar, baz",22,note\n' | other_keymap_id 3
	)" "$(
		cat <<-eof

			"bar, baz",22
		eof
	)"
}

# `--allow-ragged-csv-input` pads the short row instead of failing the whole run
function test__other_keymap_id__with_a_row_missing_cells {
	assert "$(
		printf 'a,10,x1\nb\n' | other_keymap_id 2
	)" "$(
		cat <<-eof

			a,x1
			b,
		eof
	)"
}

function test__other_keymap_ii {
	local file; file=$(
		cat <<-eof
			a,50
			b,20
			c,70
			d,40
		eof
	)

	assert "$(
		echo "$file" | other_keymap_ii 2
	)" "$(
		cat <<-eof

			b,20
			d,40
			a,50
			c,70
		eof
	)"
}

function test__other_keymap_ii__when_no_column_index {
	assert "$(
		printf 'a,50\nb,20\n' | other_keymap_ii
	)" "$(
		red_bar 'Usage: oii <index> <file>?'
	)"
}

# `1,2` is a valid `mlr` field list, but not the single index the keymap takes
function test__other_keymap_ii__with_an_invalid_column_index {
	assert "$(
		for column_index in 0 -1 abc 2.5 1,2; do
			printf 'a,50\nb,20\n' | other_keymap_ii "$column_index"
		done
	)" "$(
		for _ in $(seq 5); do
			red_bar 'Usage: oii <index> <file>?'
		done
	)"
}

function test__other_keymap_ii__with_a_file {
	local csv='/tmp/test__other_keymap_ii__with_a_file.csv'
	printf 'a,50\nb,20\nc,70\nd,40\n' > $csv

	assert "$(
		other_keymap_ii 2 $csv
	)" "$(
		cat <<-eof

			b,20
			d,40
			a,50
			c,70
		eof
	)"

	rm $csv
}

function test__other_keymap_ii__with_an_invalid_file {
	assert "$(
		# Stubbed so a broken guard fails here, as `mlr` hangs on a dir
		function other_helpers_mlr { echo 'mlr was reached'; }

		for file in /tmp/test__other_keymap__no_such.csv /tmp; do
			printf 'a,50\n' | other_keymap_ii 2 "$file"
		done
	)" "$(
		red_bar 'Invalid file: /tmp/test__other_keymap__no_such.csv'
		red_bar 'Invalid file: /tmp'
	)"
}

# A `/dev/fd/N` pipe is not a `-f` regular file, but `mlr` reads it all the same
function test__other_keymap_ii__with_a_process_substitution {
	assert "$(
		other_keymap_ii 2 <(printf 'a,50\nb,20\n')
	)" "$(
		cat <<-eof

			b,20
			a,50
		eof
	)"
}

function test__other_keymap_ii__with_windows_line_endings {
	assert "$(
		printf 'a,10,x3\r\nb,20,x1\r\nc,30,x2\r\n' | other_keymap_ii 3
	)" "$(
		cat <<-eof

			b,20,x1
			c,30,x2
			a,10,x3
		eof
	)"
}

# `sort -t,` read ` baz"` as the 2nd column here and ordered this row last
function test__other_keymap_ii__with_a_quoted_cell {
	assert "$(
		printf '"bar, baz",1\nfoo,9\n' | other_keymap_ii 2
	)" "$(
		cat <<-eof

			"bar, baz",1
			foo,9
		eof
	)"
}

function test__other_keymap_ix {
	local file; file=$(
		cat <<-eof
			a,10,x1
			b,20,x2
			c,30,x3
			d,40,x4
		eof
	)

	assert "$(
		echo "$file" | other_keymap_ix 2 3
	)" "$(
		cat <<-eof

			a,x1,10
			b,x2,20
			c,x3,30
			d,x4,40
		eof
	)"
}

function test__other_keymap_ix__when_specifying_only_one_column {
	assert "$(
		printf 'a,10,x1\n' | other_keymap_ix 2
	)" "$(
		red_bar 'Usage: oix <i1> <i2> <file>?'
	)"
}

# Either position rejects an invalid index, hence 2 bars per value
function test__other_keymap_ix__with_an_invalid_column_index {
	assert "$(
		for column_index in 0 -1 abc 2.5 1,2; do
			printf 'a,10,x1\n' | other_keymap_ix "$column_index" 3
			printf 'a,10,x1\n' | other_keymap_ix 2 "$column_index"
		done
	)" "$(
		for _ in $(seq 10); do
			red_bar 'Usage: oix <i1> <i2> <file>?'
		done
	)"
}

function test__other_keymap_ix__with_a_file {
	local csv='/tmp/test__other_keymap_ix__with_a_file.csv'
	printf 'a,10,x1\nb,20,x2\n' > $csv

	assert "$(
		other_keymap_ix 2 3 $csv
	)" "$(
		cat <<-eof

			a,x1,10
			b,x2,20
		eof
	)"

	rm $csv
}

function test__other_keymap_ix__with_an_invalid_file {
	assert "$(
		# Stubbed so a broken guard fails here, as `mlr` hangs on a dir
		function other_helpers_mlr { echo 'mlr was reached'; }

		for file in /tmp/test__other_keymap__no_such.csv /tmp; do
			printf 'a,10,x1\n' | other_keymap_ix 2 3 "$file"
		done
	)" "$(
		red_bar 'Invalid file: /tmp/test__other_keymap__no_such.csv'
		red_bar 'Invalid file: /tmp'
	)"
}

function test__other_keymap_ix__with_windows_line_endings {
	assert "$(
		printf 'a,10,x1\r\nb,20,x2\r\n' | other_keymap_ix 2 3
	)" "$(
		cat <<-eof

			a,x1,10
			b,x2,20
		eof
	)"
}

# `awk -F,` swapped ` baz"` and `22`, tearing the quoted cell in half
function test__other_keymap_ix__with_a_quoted_cell {
	assert "$(
		printf '"bar, baz",22,note\n' | other_keymap_ix 2 3
	)" "$(
		cat <<-eof

			"bar, baz",note,22
		eof
	)"
}

function test__other_keymap_k {	assert "$(
		OTHER_TERMINAL_DUMP_DIR="/tmp/test__other_keymap_k"
		rm -rf $OTHER_TERMINAL_DUMP_DIR

		echo '$' | pbcopy
		other_keymap_k
		ls -l $OTHER_TERMINAL_DUMP_DIR | wc -l
		cat $OTHER_TERMINAL_DUMP_DIR/*

		other_helpers_reset_terminal_dump_dir
		rm -rf $OTHER_TERMINAL_DUMP_DIR
	)" "$(
		cat <<-eof
			       2
			$
		eof
	)"
}

function test__other_keymap_k__when_dumping_same_pasteboard_twice {
	assert "$(
		OTHER_TERMINAL_DUMP_DIR="/tmp/test__other_keymap_k"
		rm -rf $OTHER_TERMINAL_DUMP_DIR

		echo '$' | pbcopy
		other_keymap_k
		other_keymap_k
		ls -l $OTHER_TERMINAL_DUMP_DIR | wc -l
		cat $OTHER_TERMINAL_DUMP_DIR/*

		other_helpers_reset_terminal_dump_dir
		rm -rf $OTHER_TERMINAL_DUMP_DIR
	)" "$(
		cat <<-eof
			       2
			$
		eof
	)"
}

function test__other_keymap_k__when_dumping_two_different_pasteboards {
	assert "$(
		OTHER_TERMINAL_DUMP_DIR="/tmp/test__other_keymap_k"
		rm -rf $OTHER_TERMINAL_DUMP_DIR

		printf "pasteboard 1\n$\n" | pbcopy
		other_keymap_k
		printf "pasteboard 2\n$\n" | pbcopy
		other_keymap_k
		ls -l $OTHER_TERMINAL_DUMP_DIR | wc -l
		cat $OTHER_TERMINAL_DUMP_DIR/*

		other_helpers_reset_terminal_dump_dir
		rm -rf $OTHER_TERMINAL_DUMP_DIR
	)" "$(
		cat <<-eof
			       3
			pasteboard 1
			$
			pasteboard 2
			$
		eof
	)"
}

function test__other_keymap_k__when_not_terminal_output {
	assert "$(
		# shellcheck disable=SC2030
		OTHER_TERMINAL_DUMP_DIR="/tmp/test__other_keymap_k"
		rm -rf $OTHER_TERMINAL_DUMP_DIR

		echo 'not terminal output' | pbcopy
		other_keymap_k
		ls $OTHER_TERMINAL_DUMP_DIR 2>/dev/null | wc -l

		other_helpers_reset_terminal_dump_dir
	)" '       0'
}

function test__other_keymap_kc {
	assert "$(
		# shellcheck disable=SC2030
		OTHER_TERMINAL_DUMP_DIR="/tmp/test__other_keymap_k"
		mkdir -p $OTHER_TERMINAL_DUMP_DIR

		other_keymap_kc
		[[ -e $OTHER_TERMINAL_DUMP_DIR ]] && echo present || echo absent

		other_helpers_reset_terminal_dump_dir
	)" 'absent'
}

function test__other_keymap_kk {
	# shellcheck disable=SC2031
	assert "$(
		other_keymap_kk
		pwd
	)" "$(
		cat <<-eof
			$OTHER_TERMINAL_DUMP_DIR
		eof
	)"
}

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
}

function test__other_keymap_t {
	assert "$(
		local output; output=$(other_keymap_t sleep 0.1| bw)
		# shellcheck disable=SC2076
		[[ $output =~ 'Command executed in .[0-9][0-9] seconds$' ]] && echo 1 || echo 2
	)" '1'
}

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
}

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
}

function test__other_keymap_v {
	assert "$(
		echo 'Hello world, plain text passes through.' | pbcopy
		other_keymap_v
	)" 'Hello world, plain text passes through.'
}

function test__other_keymap_v__with_urls {
	assert "$(
		pbcopy <<-'eof'
			See [this PR](https://github.com/foo/bar/pull/99) and https://example.com/a/b?c=d for details.
		eof
		other_keymap_v
	)" 'See this PR and link for details.'
}

function test__other_keymap_v__with_code_block {
	assert "$(
		pbcopy <<-'eof'
			Run this:

			```zsh
			echo secret
			```

			Then stop.
		eof
		other_keymap_v
	)" "$(
		cat <<-eof
			Run this:

			code block.

			Then stop.
		eof
	)"
}

function test__other_keymap_v__with_paths_and_hashes {
	assert "$(
		pbcopy <<-'eof'
			Edit ~/GitHub/jasonzhao6/dotfiles/zshrc/other_keymap/other_keymap.zsh at commit 2ce4712.
			Request 550e8400-e29b-41d4-a716-446655440000 kept the ratio 1/2 on 2026/07/01.
		eof
		other_keymap_v
	)" "$(
		cat <<-eof
			Edit other_keymap.zsh at commit hash.
			Request ID kept the ratio 1/2 on 2026/07/01.
		eof
	)"
}

function test__other_keymap_v__with_markdown_noise {
	assert "$(
		pbcopy <<-'eof'
			## Deploy Plan 🚀

			- **Step 1**: run `zt` now
			> Note: EW goes first

			| Program | Status |
			|---------|--------|
			| sqr     | done   |

			---

			├── zshrc/other_keymap/other_helpers.zsh
		eof
		other_keymap_v
	)" "$(
		cat <<-eof
			Deploy Plan

			Step 1: run zt now
			Note: EW goes first

			Program, Status

			sqr, done

			other_helpers.zsh
		eof
	)"
}

function test__other_keymap_w {
	local log; log=$(mktemp)

	#	Append to temp file
	other_keymap_w 0.1 "date +%s%N >> $log" &
	local pid=$!
	sleep 0.35
	kill $pid 2>/dev/null
	wait $pid 2>/dev/null

	# Expect it to have appended at least twice
	local count; count=$(wc -l < "$log")
	rm "$log"
	assert "$([[ $count -ge 2 ]] && echo 1)" '1'
}

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
}

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
}

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
}

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
}

# Miller reads the `\r` line endings; unhandled, the keys are `b\r` and `d\r`
# and nothing matches
function test__other_keymap_x__with_windows_line_endings {
	assert "$(
		other_keymap_x <(printf 'a,10\nb,20\nc,30\nd,40\n') <(printf 'b\r\nd\r\n')
	)" "$(
		cat <<-eof

			b,20
			d,40
		eof
	)"
}

# Either file arg is validated, and a dir has to be caught before `mlr` sees it
function test__other_keymap_x__with_an_invalid_file {
	assert "$(
		# Stubbed so a broken guard fails here, as `mlr` hangs on a dir
		function other_helpers_mlr { echo 'mlr was reached'; }

		other_keymap_x /tmp/test__other_keymap__no_such.csv <(printf 'a\n')
		other_keymap_x <(printf 'a,1\n') /tmp
	)" "$(
		red_bar 'Invalid file: /tmp/test__other_keymap__no_such.csv'
		red_bar 'Invalid file: /tmp'
	)"
}

# `awk -F,` read `"bar` as the 1st column of both rows and kept both
function test__other_keymap_x__with_a_quoted_cell {
	assert "$(
		other_keymap_x <(printf '"bar, baz",1\n"bar, qux",2\n') <(printf '"bar, baz"\n')
	)" "$(
		cat <<-eof

			"bar, baz",1
		eof
	)"
}

# Undeduped, `join` emits the row it matches once per repeat of the key
function test__other_keymap_x__with_a_repeated_key {
	assert "$(
		other_keymap_x <(printf 'a,1\nb,2\n') <(printf 'a\na\n')
	)" "$(
		cat <<-eof

			a,1
		eof
	)"
}

# Uncompacted, the inner call's leading blank pairs with this row's empty 1st cell
function test__other_keymap_x__with_an_empty_1st_column {
	assert "$(
		other_keymap_x <(printf ',99\nc,30\n') <(printf 'c,98\n')
	)" "$(
		cat <<-eof

			c,30
		eof
	)"
}

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
}

# Miller reads the `\r` line endings; unhandled, the keys are `a\r` and `c\r`
# and nothing is dropped
function test__other_keymap_xx__with_windows_line_endings {
	assert "$(
		other_keymap_xx <(printf 'a,10\nb,20\nc,30\nd,40\n') <(printf 'a\r\nc\r\n')
	)" "$(
		cat <<-eof

			b,20
			d,40
		eof
	)"
}

# Unpaired-right output carries no column from `file_2`, so its extra ones are
# moot and it needs no cut down to the 1st column
function test__other_keymap_xx__when_file_2_has_more_columns {
	assert "$(
		other_keymap_xx <(printf 'a,10\nb,20\nc,30\n') <(printf 'a,99\nc,98\n')
	)" "$(
		cat <<-eof

			b,20
		eof
	)"
}

function test__other_keymap_xx__with_an_invalid_file {
	assert "$(
		# Stubbed so a broken guard fails here, as `mlr` hangs on a dir
		function other_helpers_mlr { echo 'mlr was reached'; }

		other_keymap_xx /tmp/test__other_keymap__no_such.csv <(printf 'a\n')
		other_keymap_xx <(printf 'a,1\n') /tmp
	)" "$(
		red_bar 'Invalid file: /tmp/test__other_keymap__no_such.csv'
		red_bar 'Invalid file: /tmp'
	)"
}

# `awk -F,` read `"bar` as the 1st column of both rows and dropped both
function test__other_keymap_xx__with_a_quoted_cell {
	assert "$(
		other_keymap_xx <(printf '"bar, baz",1\n"bar, qux",2\n') <(printf '"bar, baz"\n')
	)" "$(
		cat <<-eof

			"bar, qux",2
		eof
	)"
}
