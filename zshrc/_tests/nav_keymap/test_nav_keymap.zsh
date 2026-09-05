function test__nav_keymap {
	assert "$(
		local show_this_help; show_this_help=$(nav_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ $show_this_help =~ "^  \\$ $NAV_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__nav_keymap__when_specifying_a_directory_instead_of_key {
	assert "$(
		rm -rf /tmp/test__nav_keymap__when_specifying_a_directory_instead_of_key
		mkdir /tmp/test__nav_keymap__when_specifying_a_directory_instead_of_key
		cd /tmp/test__nav_keymap__when_specifying_a_directory_instead_of_key || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		cd /tmp || return
		nav_keymap test__nav_keymap__when_specifying_a_directory_instead_of_key | bw
		rm -rf /tmp/test__nav_keymap__when_specifying_a_directory_instead_of_key
	)" "$(
		cat <<-eof

		     1	1
		     2	1.log
		     3	2
		     4	2.log
		     5	3
		     6	3.txt
		eof
	)"
}

function test__nav_keymap__when_specifying_a_file_instead_of_key {
	assert "$(
		rm -rf /tmp/test__nav_keymap__file
		mkdir /tmp/test__nav_keymap__file
		cd /tmp/test__nav_keymap__file || return
		echo 'one' > 1.txt
		echo 'two' > 2.txt
		echo 'three' > 3.txt
		nav_keymap_n > /dev/null
		nav_keymap 2.txt | bw
		rm -rf /tmp/test__nav_keymap__file
	)" "$(
		cat <<-eof
		─────
		2.txt
		─────

		two
		eof
	)"
}

function test__nav_keymap__when_specifying_a_file__nj_continues {
	assert "$(
		rm -rf /tmp/test__nav_keymap__file_nj
		mkdir /tmp/test__nav_keymap__file_nj
		cd /tmp/test__nav_keymap__file_nj || return
		echo 'one' > 1.txt
		echo 'two' > 2.txt
		echo 'three' > 3.txt
		nav_keymap_n > /dev/null
		nav_keymap 1.txt > /dev/null
		nav_keymap_j | bw
		rm -rf /tmp/test__nav_keymap__file_nj
	)" "$(
		cat <<-eof
		─────
		2.txt
		─────

		two
		eof
	)"
}

function test__nav_keymap__when_specifying_a_file_in_another_folder {
	# Renders the file, then stays in its containing folder
	assert "$(
		rm -rf /tmp/test__nav_keymap__file_cd
		mkdir /tmp/test__nav_keymap__file_cd
		echo 'hello' > /tmp/test__nav_keymap__file_cd/note.txt
		cd /tmp || return
		nav_keymap test__nav_keymap__file_cd/note.txt > /dev/null
		pwd
		cd /tmp && rm -rf /tmp/test__nav_keymap__file_cd
	)" '/tmp/test__nav_keymap__file_cd'
}

function test__nav_keymap__when_specifying_a_file_in_another_folder__nj_continues {
	# The folder is listed and the cursor set, so `nj` renders the next sibling
	assert "$(
		rm -rf /tmp/test__nav_keymap__file_cd_nj
		mkdir /tmp/test__nav_keymap__file_cd_nj
		echo 'one' > /tmp/test__nav_keymap__file_cd_nj/1.txt
		echo 'two' > /tmp/test__nav_keymap__file_cd_nj/2.txt
		nav_keymap /tmp/test__nav_keymap__file_cd_nj/1.txt > /dev/null
		nav_keymap_j | bw
		cd /tmp && rm -rf /tmp/test__nav_keymap__file_cd_nj
	)" "$(
		cat <<-eof
		─────
		2.txt
		─────

		two
		eof
	)"
}

function test__nav_keymap__when_specifying_a_file_not_in_args {
	# The current folder is listed and the cursor set, so `nj` renders the next file
	assert "$(
		rm -rf /tmp/test__nav_keymap__file_not_in_args
		mkdir /tmp/test__nav_keymap__file_not_in_args
		echo 'one' > /tmp/test__nav_keymap__file_not_in_args/1.txt
		echo 'two' > /tmp/test__nav_keymap__file_not_in_args/2.txt
		cd /tmp/test__nav_keymap__file_not_in_args || return
		args_history_reset
		nav_keymap 1.txt > /dev/null
		nav_keymap_j | bw
		cd /tmp && rm -rf /tmp/test__nav_keymap__file_not_in_args
	)" "$(
		cat <<-eof
		─────
		2.txt
		─────

		two
		eof
	)"
}

function test__nav_keymap__when_specifying_a_hidden_file {
	# A hidden file gets the hidden listing, so the cursor can still be set
	assert "$(
		rm -rf /tmp/test__nav_keymap__hidden
		mkdir /tmp/test__nav_keymap__hidden
		echo 'one' > /tmp/test__nav_keymap__hidden/.1.hidden
		echo 'two' > /tmp/test__nav_keymap__hidden/.2.hidden
		nav_keymap /tmp/test__nav_keymap__hidden/.1.hidden > /dev/null
		nav_keymap_j | bw
		cd /tmp && rm -rf /tmp/test__nav_keymap__hidden
	)" "$(
		cat <<-eof
		─────────
		.2.hidden
		─────────

		two
		eof
	)"
}

function test__nav_keymap__renders_md_headings_with_hash_prefixes {
	local md='/tmp/test__nav_keymap__raw_md_headings.md'
	printf '# One `span` and *em* tail\n\n## Two\n\n##### Five `code`\n\n###### Six\n' > $md

	local output; output=$(nav_keymap $md)
	local plain; plain=$(echo "$output" | bw)

	# Headings render as `#` prefixes at every level, incl. the H1 banner
	assert "$([[ $plain == *'# One'* && $plain == *'## Two'* && $plain == *'###### Six'* ]] && echo 1)" '1'

	# Headings are magenta (35)
	assert "$([[ $output =~ $'\e\\[35m# One' ]] && echo 1)" '1'
	assert "$([[ $output =~ $'\e\\[35m## ' ]] && echo 1)" '1'

	# A code span keeps its own color (33), an emphasized span keeps its italic
	# (3), and neither leaves the rest of the heading in mdcat's color
	assert "$([[ $output =~ $'\e\\[33mspan' ]] && echo 1)" '1'
	assert "$([[ $output =~ $'\e\\[3m\e\\[35mem' ]] && echo 1)" '1'
	assert "$([[ $output =~ $'\e\\[35m tail' ]] && echo 1)" '1'

	# Same at H5, the one level whose own color is the code span's yellow (33)
	assert "$([[ $output =~ $'\e\\[35m##### ' ]] && echo 1)" '1'
	assert "$([[ $output =~ $'\e\\[33mcode' ]] && echo 1)" '1'

	# The H1 banner background (104) is gone, incl. behind an inline span
	assert "$([[ $output != *$'\e[104m'* ]] && echo 1)" '1'

	# Blocks are separated by single blank lines, never runs of them
	assert "$([[ $plain != *$'\n\n\n'* ]] && echo 1)" '1'

	rm $md
}

function test__nav_keymap__renders_md_link_labels_cyan {
	local md='/tmp/test__nav_keymap__raw_md_links.md'
	printf 'a [link](https://example.com) here, wrapped by filler words pushing this [long link label across the eighty column boundary](https://example.com/foo) end\n\n## Two [inside](https://example.com) tail\n' > $md

	local output; output=$(nav_keymap $md)

	# Link labels are cyan (36), including a wrapped label's continuation line
	assert "$([[ $output =~ $'\e\\[36mlink' ]] && echo 1)" '1'
	assert "$([[ $output =~ $'\e\\[36meighty column boundary' ]] && echo 1)" '1'

	# A label inside a heading stays cyan, and the text after it is magenta
	assert "$([[ $output =~ $'\e\\[36minside' && $output =~ $'\e\\[35m tail' ]] && echo 1)" '1'

	# OSC 8 hyperlink escapes are kept
	assert "$([[ $output == *$'\e]8;;https://example.com/'* ]] && echo 1)" '1'

	rm $md
}

function test__nav_keymap__renders_csv_as_a_table {
	local csv='/tmp/test__nav_keymap__csv.csv'
	printf 'name,size,note\nfoo,1,\n"bar, baz",22,"says ""hi"""\nlonger name,333,tail\nshort\n' > $csv

	local output; output=$(nav_keymap $csv)

	# Cells are padded to their column, a quoted cell keeps its commas and
	# unescapes its quotes, and a row too short still shows its empty cells
	assert "$(echo "$output" | bw)" "$(
		cat <<-eof
		─────────────────────────
		test__nav_keymap__csv.csv
		─────────────────────────

		name        │ size │ note
		────────────┼──────┼──────────
		foo         │ 1    │
		bar, baz    │ 22   │ says "hi"
		longer name │ 333  │ tail
		short       │      │
		eof
	)"

	# The header is gray (90); its rule and every separator are also gray (90)
	assert "$([[ $output =~ $'\e\\[90mname' ]] && echo 1)" '1'
	assert "$([[ $output =~ $'\e\\[90m─' ]] && echo 1)" '1'
	assert "$([[ $output =~ $'\e\\[90m│' ]] && echo 1)" '1'

	rm $csv
}

function test__nav_keymap__renders_csv_with_multi_byte_cells {
	local csv='/tmp/test__nav_keymap__utf8.csv'
	printf 'naïve,b\nrésumé,x\nplain,yy\n' > $csv

	# Columns line up on characters, not the bytes a `ï` or `é` takes up
	assert "$(nav_keymap $csv | bw | tail -n +5)" "$(
		cat <<-eof
		naïve  │ b
		───────┼───
		résumé │ x
		plain  │ yy
		eof
	)"

	rm $csv
}

function test__nav_keymap__renders_json_with_jq {
	local json='/tmp/test__nav_keymap__json.json'
	echo '{"name":"foo","items":[1,2,3]}' > $json

	assert "$(nav_keymap $json | bw)" "$(
		cat <<-eof
		───────────────────────────
		test__nav_keymap__json.json
		───────────────────────────

		{
		  "name": "foo",
		  "items": [
		    1,
		    2,
		    3
		  ]
		}
		eof
	)"

	rm $json
}

function test__nav_keymap__when_specifying_an_arbitrary_txt_file {
	local txt='/tmp/test__nav_keymap__arbitrary_txt.txt'
	echo 'hello' > $txt

	assert "$(
		nav_keymap $txt | bw
	)" "$(
		cat <<-eof
		───────────────────────────────────
		test__nav_keymap__arbitrary_txt.txt
		───────────────────────────────────

		hello
		eof
	)"

	rm $txt
}

function test__nav_keymap_a {
	assert "$(
		rm -rf /tmp/test__nav_keymap_a
		mkdir /tmp/test__nav_keymap_a
		cd /tmp/test__nav_keymap_a || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_a | bw
		rm -rf /tmp/test__nav_keymap_a
	)" "$(
		cat <<-eof

		     1	.1.hidden
		     2	.2.hidden
		     3	.3.hidden
		eof
	)"
}

function test__nav_keymap_a__without_any_hidden_file {
	assert "$(
		rm -rf /tmp/test__nav_keymap_a
		mkdir /tmp/test__nav_keymap_a
		cd /tmp/test__nav_keymap_a || return
		mkdir 1 2 3
		touch 1.log 2.log 3.txt
		nav_keymap_a | bw
		rm -rf /tmp/test__nav_keymap_a
	)" "$(
		cat <<-eof

		     1	.
		eof
	)"
}

function test__nav_keymap_a__with_filters {
	assert "$(
		rm -rf /tmp/test__nav_keymap_a
		mkdir /tmp/test__nav_keymap_a
		cd /tmp/test__nav_keymap_a || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_a -1 hidden | bw
		rm -rf /tmp/test__nav_keymap_a
	)" "$(
		cat <<-eof

		     1	.2.hidden
		     2	.3.hidden
		eof
	)"
}

function test__nav_keymap_ad {
	assert "$(
		rm -rf /tmp/test__nav_keymap_ad
		mkdir /tmp/test__nav_keymap_ad
		cd /tmp/test__nav_keymap_ad || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_ad | bw
		rm -rf /tmp/test__nav_keymap_ad
	)" "$(
		cat <<-eof

		     1	.1.hidden/
		eof
	)"
}

function test__nav_keymap_ad__with_filters {
	assert "$(
		rm -rf /tmp/test__nav_keymap_ad
		mkdir /tmp/test__nav_keymap_ad
		cd /tmp/test__nav_keymap_ad || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_ad -1 hidden | bw
		rm -rf /tmp/test__nav_keymap_ad
	)" ''
}

function test__nav_keymap_af {
	assert "$(
		rm -rf /tmp/test__nav_keymap_af
		mkdir /tmp/test__nav_keymap_af
		cd /tmp/test__nav_keymap_af || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_af | bw
		rm -rf /tmp/test__nav_keymap_af
	)" "$(
		cat <<-eof

		     1	.2.hidden
		     2	.3.hidden
		eof
	)"
}

function test__nav_keymap_af__with_filters {
	assert "$(
		rm -rf /tmp/test__nav_keymap_af
		mkdir /tmp/test__nav_keymap_af
		cd /tmp/test__nav_keymap_af || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_af -3 hidden | bw
		rm -rf /tmp/test__nav_keymap_af
	)" "$(
		cat <<-eof

		     1	.2.hidden
		eof
	)"
}

function test__nav_keymap_b {
	assert "$(nav_keymap_b > /dev/null; pwd)" "$HOME/Desktop"
}

function test__nav_keymap_d {
	assert "$(nav_keymap_d > /dev/null; pwd)" "$HOME/GitHub/jasonzhao6/dotfiles"
}

function test__nav_keymap_e__single_match_cds_and_invokes_claude {
	local tmp_dir="$NAV_EPHEMERAL_DIR/test__nav_keymap_e__single_match"
	local marker="/tmp/test__nav_keymap_e__single_match.marker"
	mkdir -p "$tmp_dir"
	rm -f "$marker"

	assert "$(
		function claude_keymap_c { touch "$marker" }

		nav_keymap_e test__nav_keymap_e__single_match > /dev/null

		[[ -f $marker ]] && echo 'called'
		pwd
	)" "$(
		cat <<-eof
			called
			$tmp_dir
		eof
	)"

	rm -rf "$tmp_dir" "$marker"
}

function test__nav_keymap_e__multiple_matches_stay_and_skips_claude {
	local tmp_dir_1="$NAV_EPHEMERAL_DIR/test__nav_keymap_e__multi_1"
	local tmp_dir_2="$NAV_EPHEMERAL_DIR/test__nav_keymap_e__multi_2"
	local marker="/tmp/test__nav_keymap_e__multi.marker"
	mkdir -p "$tmp_dir_1" "$tmp_dir_2"
	rm -f "$marker"

	assert "$(
		function claude_keymap_c { touch "$marker" }

		nav_keymap_e test__nav_keymap_e__multi > /dev/null

		[[ -f $marker ]] && echo 'called'
		pwd
	)" "$NAV_EPHEMERAL_DIR"

	rm -rf "$tmp_dir_1" "$tmp_dir_2" "$marker"
}

function test__nav_keymap_e__no_match_stays_and_skips_claude {
	local marker="/tmp/test__nav_keymap_e__no_match.marker"
	rm -f "$marker"

	assert "$(
		function claude_keymap_c { touch "$marker" }

		nav_keymap_e zzz-no-such-dir > /dev/null

		[[ -f $marker ]] && echo 'called'
		pwd
	)" "$NAV_EPHEMERAL_DIR"

	rm -f "$marker"
}

function test__nav_keymap_ee__creates_and_cds {
	local target_dir="$NAV_EPHEMERAL_DIR/test__nav_keymap_ee__new"
	rm -rf "$target_dir"

	assert "$(
		function claude_keymap_c { echo 'claude_keymap_c called' }

		nav_keymap_ee test__nav_keymap_ee__new
		pwd
	)" "$(
		cat <<-eof
			claude_keymap_c called
			$target_dir
		eof
	)"

	rm -rf "$target_dir"
}

function test__nav_keymap_ee__existing_folder_errors {
	local target_dir="$NAV_EPHEMERAL_DIR/test__nav_keymap_ee__existing"
	mkdir -p "$target_dir"

	assert "$(nav_keymap_ee test__nav_keymap_ee__existing)" "$(red_bar 'Ephemeral dir already exists: test__nav_keymap_ee__existing')"

	rm -rf "$target_dir"
}

function test__nav_keymap_ee__no_name_errors {
	assert "$(nav_keymap_ee)" "$(red_bar 'Usage: nee <dir name>')"
}

function test__nav_keymap_h {
	assert "$(
		rm -f "$NAV_HISTORY_FILE"
		echo "$HOME/Documents" >> "$NAV_HISTORY_FILE"
		echo "$HOME/Downloads" >> "$NAV_HISTORY_FILE"
		nav_keymap_h | bw | grep -v '^$' | wc -l | tr -d ' '
	)" '2'
}

function test__nav_keymap_h__with_filters {
	assert "$(
		rm -f "$NAV_HISTORY_FILE"
		echo "$HOME/Documents" >> "$NAV_HISTORY_FILE"
		echo "$HOME/Downloads" >> "$NAV_HISTORY_FILE"
		echo "$HOME/Desktop" >> "$NAV_HISTORY_FILE"
		nav_keymap_h Do | bw | grep -v '^$' | wc -l | tr -d ' '
	)" '2'
}

function test__nav_keymap_h__empty {
	assert "$(
		rm -f "$NAV_HISTORY_FILE"
		nav_keymap_h
	)" "$(red_bar 'Navigation history is empty')"
}

function test__nav_keymap_h__single_entry_cds {
	assert "$(
		rm -f "$NAV_HISTORY_FILE"
		echo "$HOME/Documents" >> "$NAV_HISTORY_FILE"
		nav_keymap_h > /dev/null
		pwd
	)" "$HOME/Documents"
}

function test__nav_keymap_h__single_match_cds {
	assert "$(
		rm -f "$NAV_HISTORY_FILE"
		echo "$HOME/Documents" >> "$NAV_HISTORY_FILE"
		echo "$HOME/Downloads" >> "$NAV_HISTORY_FILE"
		echo "$HOME/Desktop" >> "$NAV_HISTORY_FILE"
		nav_keymap_h Down > /dev/null
		pwd
	)" "$HOME/Downloads"
}

function test__nav_keymap_h__oldest_first {
	assert "$(
		rm -f "$NAV_HISTORY_FILE"
		echo "$HOME/Desktop" >> "$NAV_HISTORY_FILE"
		echo "$HOME/Documents" >> "$NAV_HISTORY_FILE"
		nav_keymap_h | bw | grep -v '^$' | head -1 | sed 's/^[[:space:]]*[0-9]*\t//'
	)" "$HOME/Desktop"
}

function test__nav_keymap_h__shows_capture_time {
	assert "$(
		rm -f "$NAV_HISTORY_FILE"
		nav_helpers_history_add "$HOME/Documents"
		nav_keymap_h | bw | grep -v '^$' | grep -cE '# [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$'
	)" '1'
}

function test__nav_keymap_h__aligns_capture_times {
	assert "$(
		rm -f "$NAV_HISTORY_FILE"
		nav_helpers_history_add "$HOME/Documents"
		nav_helpers_history_add "$HOME/a"
		nav_keymap_h | bw | grep -v '^$' | awk '{print index($0, "#")}' | sort -u | wc -l | tr -d ' '
	)" '1'
}

function test__nav_keymap_h__single_match_cds_with_capture_time {
	assert "$(
		rm -f "$NAV_HISTORY_FILE"
		nav_helpers_history_add "$HOME/Documents"
		nav_keymap_h > /dev/null
		pwd
	)" "$HOME/Documents"
}

function test__nav_keymap_h__skips_consecutive_duplicates {
	assert "$(
		rm -f "$NAV_HISTORY_FILE"
		nav_helpers_history_add "$HOME/Documents"
		nav_helpers_history_add "$HOME/Documents"
		nav_helpers_history_add "$HOME/Downloads"
		nav_helpers_history_add "$HOME/Downloads"
		nav_helpers_history_add "$HOME/Documents"
		wc -l < "$NAV_HISTORY_FILE" | tr -d ' '
	)" '3'
}

function test__nav_keymap_h__trims_to_max_entries {
	assert "$(
		# shellcheck disable=SC2030 # Overriding inside $(...) for isolation; subshell-local is intended
		NAV_HISTORY_MAX=3

		rm -f "$NAV_HISTORY_FILE"
		local dir
		for dir in 1 2 3 4 5; do
			nav_helpers_history_add "$HOME/dir$dir"
		done

		sed 's/ #.*//' "$NAV_HISTORY_FILE"
	)" "$(
		cat <<-eof
			$HOME/dir3
			$HOME/dir4
			$HOME/dir5
		eof
	)"
}

function test__nav_keymap_hc {
	assert "$(
		rm -f "$NAV_HISTORY_FILE"
		echo "$HOME/Documents" >> "$NAV_HISTORY_FILE"
		echo "$HOME/Downloads" >> "$NAV_HISTORY_FILE"
		nav_keymap_hc
		[[ -f "$NAV_HISTORY_FILE" ]] && echo 'file exists' || echo 'file gone'
	)" "$(printf '%s\n%s' "$(green_bar 'Cleared 2 history entries')" 'file gone')"
}

function test__nav_keymap_hc__empty {
	assert "$(
		rm -f "$NAV_HISTORY_FILE"
		nav_keymap_hc
	)" "$(red_bar 'Navigation history is empty')"
}

function test__nav_keymap_j {
	assert "$(
		rm -rf /tmp/test__nav_keymap_j
		mkdir /tmp/test__nav_keymap_j
		cd /tmp/test__nav_keymap_j || return
		echo 'one' > 1.txt
		echo 'two' > 2.txt
		echo 'three' > 3.txt
		nav_keymap_n > /dev/null
		(nav_keymap_j; nav_keymap_j; nav_keymap_j) | bw
		rm -rf /tmp/test__nav_keymap_j
	)" "$(
		cat <<-eof
		─────
		1.txt
		─────

		one
		─────
		2.txt
		─────

		two
		─────
		3.txt
		─────

		three
		eof
	)"
}

function test__nav_keymap_j__populates_empty_args {
	# In a fresh shell with no args yet, list the cwd first, then render file 1
	assert "$(
		rm -rf /tmp/test__nav_keymap_j
		mkdir /tmp/test__nav_keymap_j
		cd /tmp/test__nav_keymap_j || return
		echo 'one' > 1.txt
		echo 'two' > 2.txt
		args_history_reset
		NAV_CURSOR=0
		nav_keymap_j | bw
		rm -rf /tmp/test__nav_keymap_j
	)" "$(
		cat <<-eof
		─────
		1.txt
		─────

		one
		eof
	)"
}

function test__nav_keymap_j__when_at_end {
	assert "$(
		rm -rf /tmp/test__nav_keymap_j
		mkdir /tmp/test__nav_keymap_j
		cd /tmp/test__nav_keymap_j || return
		echo 'one' > 1.txt
		nav_keymap_n > /dev/null
		nav_keymap_j > /dev/null
		nav_keymap_j | bw
		rm -rf /tmp/test__nav_keymap_j
	)" "$(red_bar 'Reached the end of file list' | bw)"
}

function test__nav_keymap_j__renders_md_with_nav_helpers {
	assert "$(
		rm -rf /tmp/test__nav_keymap_j
		mkdir /tmp/test__nav_keymap_j
		cd /tmp/test__nav_keymap_j || return
		printf '# Heading\n\n- item\n' > note.md
		nav_keymap_n > /dev/null
		# The `•` proves mdcat rendered the file, rather than `cat` printing it
		nav_keymap_j | bw | compact
		rm -rf /tmp/test__nav_keymap_j
	)" "$(
		cat <<-eof
		───────
		note.md
		───────
		# Heading
		• item
		eof
	)"
}

function test__nav_keymap_j__cats_log {
	assert "$(
		rm -rf /tmp/test__nav_keymap_j
		mkdir /tmp/test__nav_keymap_j
		cd /tmp/test__nav_keymap_j || return
		echo 'logged' > app.log
		nav_keymap_n > /dev/null
		nav_keymap_j | bw
		rm -rf /tmp/test__nav_keymap_j
	)" "$(
		cat <<-eof
		───────
		app.log
		───────

		logged
		eof
	)"
}

function test__nav_keymap_j__cats_unknown_type {
	assert "$(
		rm -rf /tmp/test__nav_keymap_j
		mkdir /tmp/test__nav_keymap_j
		cd /tmp/test__nav_keymap_j || return
		echo 'binary-ish' > unknown.bin
		nav_keymap_n > /dev/null
		nav_keymap_j | bw
		rm -rf /tmp/test__nav_keymap_j
	)" "$(
		cat <<-eof
		───────────
		unknown.bin
		───────────

		binary-ish
		eof
	)"
}

function test__nav_keymap_j__resets_on_nn {
	assert "$(
		rm -rf /tmp/test__nav_keymap_j
		mkdir /tmp/test__nav_keymap_j
		cd /tmp/test__nav_keymap_j || return
		echo 'one' > 1.txt
		echo 'two' > 2.txt
		nav_keymap_n > /dev/null
		nav_keymap_j > /dev/null
		nav_keymap_j > /dev/null  # cursor at 2 (end)
		nav_keymap_n > /dev/null  # should reset cursor to 0
		nav_keymap_j | bw  # should show 1.txt again
		rm -rf /tmp/test__nav_keymap_j
	)" "$(
		cat <<-eof
		─────
		1.txt
		─────

		one
		eof
	)"
}

function test__nav_keymap_k {
	assert "$(
		rm -rf /tmp/test__nav_keymap_k
		mkdir /tmp/test__nav_keymap_k
		cd /tmp/test__nav_keymap_k || return
		echo 'one' > 1.txt
		echo 'two' > 2.txt
		echo 'three' > 3.txt
		nav_keymap_n > /dev/null
		(nav_keymap_k; nav_keymap_k; nav_keymap_k) | bw
		rm -rf /tmp/test__nav_keymap_k
	)" "$(
		cat <<-eof
		─────
		3.txt
		─────

		three
		─────
		2.txt
		─────

		two
		─────
		1.txt
		─────

		one
		eof
	)"
}

function test__nav_keymap_k__when_at_beginning {
	assert "$(
		rm -rf /tmp/test__nav_keymap_k
		mkdir /tmp/test__nav_keymap_k
		cd /tmp/test__nav_keymap_k || return
		echo 'one' > 1.txt
		nav_keymap_n > /dev/null
		nav_keymap_k > /dev/null
		nav_keymap_k | bw
		rm -rf /tmp/test__nav_keymap_k
	)" "$(red_bar 'Reached the beginning of file list' | bw)"
}

function test__nav_keymap_k__after_nj_decrements {
	assert "$(
		rm -rf /tmp/test__nav_keymap_k
		mkdir /tmp/test__nav_keymap_k
		cd /tmp/test__nav_keymap_k || return
		echo 'one' > 1.txt
		echo 'two' > 2.txt
		echo 'three' > 3.txt
		nav_keymap_n > /dev/null
		nav_keymap_j > /dev/null  # cursor=1
		nav_keymap_j > /dev/null  # cursor=2
		nav_keymap_j > /dev/null  # cursor=3
		nav_keymap_k | bw  # cursor=2 → 2.txt
		rm -rf /tmp/test__nav_keymap_k
	)" "$(
		cat <<-eof
		─────
		2.txt
		─────

		two
		eof
	)"
}

function test__nav_keymap_k__populates_empty_args {
	# In a fresh shell with no args yet, list the cwd first, then wrap to the last file
	assert "$(
		rm -rf /tmp/test__nav_keymap_k
		mkdir /tmp/test__nav_keymap_k
		cd /tmp/test__nav_keymap_k || return
		echo 'one' > 1.txt
		echo 'two' > 2.txt
		args_history_reset
		NAV_CURSOR=0
		nav_keymap_k | bw
		rm -rf /tmp/test__nav_keymap_k
	)" "$(
		cat <<-eof
		─────
		2.txt
		─────

		two
		eof
	)"
}

function test__nav_keymap_m {
	assert "$(nav_keymap_m > /dev/null; pwd)" "$HOME/Documents"
}

function test__nav_keymap_n {
	assert "$(
		rm -rf /tmp/test__nav_keymap_n
		mkdir /tmp/test__nav_keymap_n
		cd /tmp/test__nav_keymap_n || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_n | bw
		rm -rf /tmp/test__nav_keymap_n
	)" "$(
		cat <<-eof

		     1	1
		     2	1.log
		     3	2
		     4	2.log
		     5	3
		     6	3.txt
		eof
	)"
}

function test__nav_keymap_n__with_filters {
	assert "$(
		rm -rf /tmp/test__nav_keymap_n
		mkdir /tmp/test__nav_keymap_n
		cd /tmp/test__nav_keymap_n || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_n -1 log | bw
		rm -rf /tmp/test__nav_keymap_n
	)" "$(
		cat <<-eof

		     1	2.log
		eof
	)"
}

function test__nav_keymap_nd {
	assert "$(
		rm -rf /tmp/test__nav_keymap_nd
		mkdir /tmp/test__nav_keymap_nd
		cd /tmp/test__nav_keymap_nd || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_nd | bw
		rm -rf /tmp/test__nav_keymap_nd
	)" "$(
		cat <<-eof

		     1	1/
		     2	2/
		     3	3/
		eof
	)"
}

function test__nav_keymap_nd__with_filters {
	assert "$(
		rm -rf /tmp/test__nav_keymap_nd
		mkdir /tmp/test__nav_keymap_nd
		cd /tmp/test__nav_keymap_nd || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_nd -1 | bw
		rm -rf /tmp/test__nav_keymap_nd
	)" "$(
		cat <<-eof

		     1	2/
		     2	3/
		eof
	)"
}

function test__nav_keymap_nf {
	assert "$(
		rm -rf /tmp/test__nav_keymap_nf
		mkdir /tmp/test__nav_keymap_nf
		cd /tmp/test__nav_keymap_nf || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_nf | bw
		rm -rf /tmp/test__nav_keymap_nf
	)" "$(
		cat <<-eof

		     1	1.log
		     2	2.log
		     3	3.txt
		eof
	)"
}

function test__nav_keymap_nf__with_filters {
	assert "$(
		rm -rf /tmp/test__nav_keymap_nf
		mkdir /tmp/test__nav_keymap_nf
		cd /tmp/test__nav_keymap_nf || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_nf -1 log | bw
		rm -rf /tmp/test__nav_keymap_nf
	)" "$(
		cat <<-eof

		     1	2.log
		eof
	)"
}

function test__nav_keymap_o {
	assert "$(
		rm -rf /tmp/test__nav_keymap_o
		mkdir /tmp/test__nav_keymap_o
		cd /tmp/test__nav_keymap_o || return
		touch -t 202301010000 .hidden
		touch -t 202401010000 visible.txt
		local output; output=$(nav_keymap_o | bw)
		# Should include .hidden but not . or ..
		echo "$output" | wc -l | tr -d ' '
		echo "$output" | head -1 | awk '{print $NF}'
		echo "$output" | tail -1 | awk '{print $NF}'
		rm -rf /tmp/test__nav_keymap_o
	)" "$(
		cat <<-eof
			2
			.hidden
			visible.txt
		eof
	)"
}

function test__nav_keymap_od {
	assert "$(
		rm -rf /tmp/test__nav_keymap_od
		mkdir -p /tmp/test__nav_keymap_od/sub1
		mkdir -p /tmp/test__nav_keymap_od/sub2
		cd /tmp/test__nav_keymap_od || return
		dd if=/dev/zero of=sub1/f.txt bs=1024 count=1 2>/dev/null
		local output; output=$(nav_keymap_od)
		# du -hd1 returns: sub1, sub2, and . (3 lines total)
		echo "$output" | wc -l | tr -d ' '
		rm -rf /tmp/test__nav_keymap_od
	)" '3'
}

function test__nav_keymap_of {
	assert "$(
		rm -rf /tmp/test__nav_keymap_of
		mkdir /tmp/test__nav_keymap_of
		cd /tmp/test__nav_keymap_of || return
		dd if=/dev/zero of=.hidden bs=1 count=50 2>/dev/null
		dd if=/dev/zero of=visible.txt bs=1 count=100 2>/dev/null
		local output; output=$(nav_keymap_of | bw)
		# Should include .hidden but not . or ..
		echo "$output" | wc -l | tr -d ' '
		echo "$output" | head -1 | awk '{print $NF}'
		echo "$output" | tail -1 | awk '{print $NF}'
		rm -rf /tmp/test__nav_keymap_of
	)" "$(
		cat <<-eof
			2
			.hidden
			visible.txt
		eof
	)"
}

function test__nav_keymap_of__excludes_dirs {
	assert "$(
		rm -rf /tmp/test__nav_keymap_of
		mkdir /tmp/test__nav_keymap_of
		cd /tmp/test__nav_keymap_of || return
		mkdir subdir
		dd if=/dev/zero of=file.txt bs=1 count=100 2>/dev/null
		local output; output=$(nav_keymap_of | bw)
		# Should only include file.txt, not subdir
		echo "$output" | wc -l | tr -d ' '
		echo "$output" | awk '{print $NF}'
		rm -rf /tmp/test__nav_keymap_of
	)" "$(
		cat <<-eof
			1
			file.txt
		eof
	)"
}

function test__nav_keymap_p__with_dir {
	assert "$(
		echo "$HOME/Documents" | pbcopy
		nav_keymap_p > /dev/null
		pwd
	)" "$HOME/Documents"
}

function test__nav_keymap_p__with_file {
	assert "$(
		touch /tmp/test__nav_keymap_p__with_file
		echo '/tmp/test__nav_keymap_p__with_file' | pbcopy
		nav_keymap_p > /dev/null
		pwd
		rm -f /tmp/test__nav_keymap_p__with_file
	)" '/tmp'
}

function test__nav_keymap_p__with_invalid_path {
	assert "$(
		echo 'does not exist' | pbcopy
		nav_keymap_p
	)" "$(red_bar 'Invalid path in pasteboard')"
}

function test__nav_keymap_p__with_tilde_dir {
	assert "$(
		# shellcheck disable=SC2088 # Literal ~ is intentional test input (a pasted path)
		echo '~/Documents' | pbcopy
		nav_keymap_p > /dev/null
		pwd
	)" "$HOME/Documents"
}

function test__nav_keymap_p__with_tilde_file {
	assert "$(
		touch "$HOME/test__nav_keymap_p__with_tilde_file"
		# shellcheck disable=SC2088 # Literal ~ is intentional test input (a pasted path)
		echo '~/test__nav_keymap_p__with_tilde_file' | pbcopy
		nav_keymap_p > /dev/null
		pwd
		rm -f "$HOME/test__nav_keymap_p__with_tilde_file"
	)" "$HOME"
}

function test__nav_keymap_p__with_trailing_metadata {
	assert "$(
		local repo=/tmp/test__nav_keymap_p__with_trailing_metadata
		rm -rf "$repo"
		mkdir -p "$repo"
		echo "$repo #jz mq01-qa.team-transaction-engine-dev us-east-1" | pbcopy
		nav_keymap_p > /dev/null
		pwd
		rm -rf "$repo"
	)" '/tmp/test__nav_keymap_p__with_trailing_metadata'
}

function test__nav_keymap_p__with_path_containing_space_and_metadata {
	assert "$(
		local repo='/tmp/test__nav_keymap_p hello world #eou'
		rm -rf "$repo"
		mkdir -p "$repo"
		echo "$repo mq01-qa.team-transaction-engine-dev us-east-1" | pbcopy
		nav_keymap_p > /dev/null
		pwd
		rm -rf "$repo"
	)" '/tmp/test__nav_keymap_p hello world #eou'
}

function test__nav_keymap_p__with_tilde_and_metadata {
	assert "$(
		# shellcheck disable=SC2088 # Literal ~ is intentional test input (a pasted path)
		echo '~/Documents #jz mq01-qa.team-transaction-engine-dev us-east-1' | pbcopy
		nav_keymap_p > /dev/null
		pwd
	)" "$HOME/Documents"
}

function test__nav_keymap_p__with_file_and_metadata {
	assert "$(
		touch /tmp/test__nav_keymap_p__with_file_and_metadata
		echo '/tmp/test__nav_keymap_p__with_file_and_metadata #jz us-east-1' | pbcopy
		nav_keymap_p > /dev/null
		pwd
		rm -f /tmp/test__nav_keymap_p__with_file_and_metadata
	)" '/tmp'
}

function test__nav_keymap_p__with_surrounding_whitespace {
	# The resolver strips surrounding whitespace before validating the path
	assert "$(
		touch /tmp/test__nav_keymap_p__whitespace.txt
		printf '  /tmp/test__nav_keymap_p__whitespace.txt  ' | pbcopy
		nav_keymap_p > /dev/null
		pwd
		rm -f /tmp/test__nav_keymap_p__whitespace.txt
	)" '/tmp'
}

function test__nav_keymap_r {
	assert "$(
		rm -rf /tmp/test__nav_keymap_r
		mkdir /tmp/test__nav_keymap_r
		cd /tmp/test__nav_keymap_r || return
		echo 'one' > 1.txt
		echo 'two' > 2.txt
		nav_keymap_n > /dev/null
		nav_keymap_j > /dev/null  # cursor=1
		nav_keymap_r | bw  # reprint 1.txt without moving cursor
		rm -rf /tmp/test__nav_keymap_r
	)" "$(
		cat <<-eof
		─────
		1.txt
		─────

		one
		eof
	)"
}

function test__nav_keymap_r__on_fresh_list {
	assert "$(
		rm -rf /tmp/test__nav_keymap_r
		mkdir /tmp/test__nav_keymap_r
		cd /tmp/test__nav_keymap_r || return
		echo 'one' > 1.txt
		nav_keymap_n > /dev/null  # cursor=0, fresh list
		nav_keymap_r | bw  # should print first file like nj
		rm -rf /tmp/test__nav_keymap_r
	)" "$(
		cat <<-eof
		─────
		1.txt
		─────

		one
		eof
	)"
}

function test__nav_keymap_r__when_empty {
	assert "$(
		rm -rf /tmp/test__nav_keymap_r
		mkdir /tmp/test__nav_keymap_r
		cd /tmp/test__nav_keymap_r || return
		nav_keymap_n > /dev/null
		nav_keymap_r | bw
		rm -rf /tmp/test__nav_keymap_r
	)" "$(red_bar 'No current file in the list' | bw)"
}

function test__nav_keymap_r__populates_empty_args {
	# In a fresh shell with no args yet, list the cwd first, then render file 1
	assert "$(
		rm -rf /tmp/test__nav_keymap_r
		mkdir /tmp/test__nav_keymap_r
		cd /tmp/test__nav_keymap_r || return
		echo 'one' > 1.txt
		echo 'two' > 2.txt
		args_history_reset
		NAV_CURSOR=0
		nav_keymap_r | bw
		rm -rf /tmp/test__nav_keymap_r
	)" "$(
		cat <<-eof
		─────
		1.txt
		─────

		one
		eof
	)"
}

function test__nav_keymap_r__reflects_updated_content {
	assert "$(
		rm -rf /tmp/test__nav_keymap_r
		mkdir /tmp/test__nav_keymap_r
		cd /tmp/test__nav_keymap_r || return
		echo 'before' > 1.txt
		nav_keymap_n > /dev/null
		nav_keymap_j > /dev/null
		echo 'after' > 1.txt
		nav_keymap_r | bw
		rm -rf /tmp/test__nav_keymap_r
	)" "$(
		cat <<-eof
		─────
		1.txt
		─────

		after
		eof
	)"
}

function test__nav_keymap_s {
	assert "$(nav_keymap_s > /dev/null; pwd)" "$HOME/GitHub/jasonzhao6/scratch"
}

function test__nav_keymap_t {
	assert "$(
		printf '%s\n%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" > "$NAV_SHORTLIST_FILE"
		nav_keymap_t | bw
	)" "$(
		cat <<-eof

		     1	$HOME/Documents
		     2	$HOME/Downloads
		     3	$HOME/Desktop
		eof
	)"
}

function test__nav_keymap_t__with_filters {
	assert "$(
		printf '%s\n%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" > "$NAV_SHORTLIST_FILE"
		nav_keymap_t Do | bw
	)" "$(
		cat <<-eof

		     1	$HOME/Documents
		     2	$HOME/Downloads
		eof
	)"
}

function test__nav_keymap_t__single_entry_cds {
	assert "$(
		printf '%s\n' "$HOME/Downloads" > "$NAV_SHORTLIST_FILE"
		nav_keymap_t > /dev/null
		pwd
	)" "$HOME/Downloads"
}

function test__nav_keymap_t__single_match_cds {
	assert "$(
		printf '%s\n%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" > "$NAV_SHORTLIST_FILE"
		nav_keymap_t Down > /dev/null
		pwd
	)" "$HOME/Downloads"
}

function test__nav_keymap_t__empty {
	assert "$(
		rm -f "$NAV_SHORTLIST_FILE"
		nav_keymap_t
	)" "$(red_bar 'Path shortlist is empty')"
}

function test__nav_keymap_t__prunes_missing_dirs {
	local gone=/tmp/test__nav_keymap_t__prunes_missing_dirs
	rm -rf "$gone"

	printf '%s\n%s\n%s\n' "$HOME/Documents" "$gone" "$HOME/Downloads" > "$NAV_SHORTLIST_FILE"

	# Missing dir is dropped from the listing
	assert "$(nav_keymap_t | bw)" "$(
		cat <<-eof

		     1	$HOME/Documents
		     2	$HOME/Downloads
		eof
	)"

	# Missing dir is removed from the MRU file
	assert "$(cat "$NAV_SHORTLIST_FILE")" "$(printf '%s\n%s' "$HOME/Documents" "$HOME/Downloads")"
}

function test__nav_keymap_t__prunes_to_empty {
	local gone=/tmp/test__nav_keymap_t__prunes_to_empty
	rm -rf "$gone"

	assert "$(
		printf '%s\n' "$gone" > "$NAV_SHORTLIST_FILE"
		nav_keymap_t
	)" "$(red_bar 'Path shortlist is empty')"
}

function test__nav_keymap_tc {
	assert "$(
		echo "$HOME/Documents" > "$NAV_SHORTLIST_FILE"
		nav_keymap_tc
		[[ ! -f "$NAV_SHORTLIST_FILE" ]] && echo 'cleared'
	)" 'cleared'
}

function test__nav_keymap_td {
	assert "$(
		printf '%s\n%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" > "$NAV_SHORTLIST_FILE"
		nav_keymap_td "$HOME/Downloads" > /dev/null
		cat "$NAV_SHORTLIST_FILE"
	)" "$(printf '%s\n%s' "$HOME/Documents" "$HOME/Desktop")"
}

function test__nav_keymap_td__relists {
	assert "$(
		printf '%s\n%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" > "$NAV_SHORTLIST_FILE"
		nav_keymap_td "$HOME/Downloads" | bw
	)" "$(
		cat <<-eof

		     1	$HOME/Documents
		     2	$HOME/Desktop
		eof
	)"
}

function test__nav_keymap_td__not_found {
	assert "$(
		printf '%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" > "$NAV_SHORTLIST_FILE"
		nav_keymap_td "$HOME/Desktop"
	)" "$(red_bar 'Path not found in shortlist')"
}

function test__nav_keymap_td__usage_error {
	assert "$(
		printf '%s\n' "$HOME/Documents" > "$NAV_SHORTLIST_FILE"
		nav_keymap_td
	)" "$(red_bar 'Usage: ntd <dir>')"
}

function test__nav_keymap_td__empty {
	assert "$(
		rm -f "$NAV_SHORTLIST_FILE"
		nav_keymap_td "$HOME/Documents"
	)" "$(red_bar 'Path shortlist is empty')"
}

function test__nav_keymap_tt {
	assert "$(
		rm -f "$NAV_SHORTLIST_FILE"
		cd "$HOME/Documents" || return
		nav_keymap_tt
		head -1 "$NAV_SHORTLIST_FILE"
	)" "$HOME/Documents"
}

function test__nav_keymap_tt__with_relative_path {
	assert "$(
		rm -f "$NAV_SHORTLIST_FILE"
		cd "$HOME" || return
		nav_keymap_tt Documents > /dev/null
		head -1 "$NAV_SHORTLIST_FILE"
	)" "$HOME/Documents"
}

function test__nav_keymap_tt__with_another_dir__cds_into_it {
	assert "$(
		rm -f "$NAV_SHORTLIST_FILE"
		cd "$HOME" || return
		nav_keymap_tt Documents > /dev/null
		pwd
	)" "$HOME/Documents"
}

# Both of these already sit in the dir, so there is nowhere to follow; without the
# guard, `nav_keymap_n` would print a listing over an otherwise silent add
function test__nav_keymap_tt__without_dir__stays_put {
	assert "$(
		rm -f "$NAV_SHORTLIST_FILE"
		cd "$HOME/Documents" || return
		nav_keymap_tt
		pwd
	)" "$HOME/Documents"
}

function test__nav_keymap_tt__with_current_dir__stays_put {
	assert "$(
		rm -f "$NAV_SHORTLIST_FILE"
		cd "$HOME/Documents" || return
		nav_keymap_tt .
		pwd
	)" "$HOME/Documents"
}

function test__nav_keymap_tt__with_invalid_path {
	assert "$(
		rm -f "$NAV_SHORTLIST_FILE"
		nav_keymap_tt /nonexistent/path 2>&1 > /dev/null
		[[ ! -f "$NAV_SHORTLIST_FILE" ]] && echo 'not added'
	)" 'not added'
}

function test__nav_keymap_tt__with_invalid_dir__shows_error {
	assert "$(
		nav_keymap_tt /nonexistent/path
	)" "$(red_bar 'Invalid dir: /nonexistent/path')"
}

function test__nav_keymap_tt__appends_to_shortlist {
	assert "$(
		rm -f "$NAV_SHORTLIST_FILE"
		cd "$HOME/Downloads" || return
		nav_keymap_tt
		cd "$HOME/Documents" || return
		nav_keymap_tt
		cat "$NAV_SHORTLIST_FILE"
	)" "$(printf '%s\n%s' "$HOME/Documents" "$HOME/Downloads")"
}

function test__nav_keymap_tt__skips_duplicate_entry {
	assert "$(
		rm -f "$NAV_SHORTLIST_FILE"
		cd "$HOME/Downloads" || return
		nav_keymap_tt
		cd "$HOME/Documents" || return
		nav_keymap_tt
		cd "$HOME/Downloads" || return
		nav_keymap_tt
		cat "$NAV_SHORTLIST_FILE"
	)" "$(printf '%s\n%s' "$HOME/Documents" "$HOME/Downloads")"
}

function test__nav_keymap_u {
	assert "$(
		rm -rf /tmp/_nav_keymap_u
		mkdir -p /tmp/_nav_keymap_u/1
		cd /tmp/_nav_keymap_u/1 || return
		nav_keymap_u > /dev/null
		pwd
		rm -rf /tmp/_nav_keymap_u
	)" '/tmp/_nav_keymap_u'
}

function test__nav_keymap_u__with_levels {
	assert "$(
		rm -rf /tmp/_nav_keymap_u
		mkdir -p /tmp/_nav_keymap_u/1/2/3
		cd /tmp/_nav_keymap_u/1/2/3 || return
		nav_keymap_u 3 > /dev/null
		pwd
		rm -rf /tmp/_nav_keymap_u
	)" '/tmp/_nav_keymap_u'
}

# `0`, `-1`, and `abc` used to fall through the loop and `cd ''`, staying put
# while still printing a listing, so they looked like they had worked
function test__nav_keymap_u__with_invalid_levels {
	assert "$(
		rm -rf /tmp/_nav_keymap_u
		mkdir -p /tmp/_nav_keymap_u/1
		cd /tmp/_nav_keymap_u/1 || return
		for levels in 0 -1 abc 2.5; do
			nav_keymap_u "$levels"
			pwd
		done
		rm -rf /tmp/_nav_keymap_u
	)" "$(
		for _ in 1 2 3 4; do
			red_bar 'Usage: nu <levels>'
			echo '/tmp/_nav_keymap_u/1'
		done
	)"
}

function test__nav_keymap_uu {
	assert "$(
		cd ~/GitHub/jasonzhao6/dotfiles/zshrc/_tests || return
		nav_keymap_uu > /dev/null
		pwd
	)" "$HOME/GitHub/jasonzhao6/dotfiles"
}

function test__nav_keymap_uu__when_not_in_repo {
	assert "$(
		cd /tmp || return
		nav_keymap_uu
	)" "$(red_bar 'Not in a git repo')"
}

function test__nav_keymap_v__renders_pasteboard_file {
	local md='/tmp/test__nav_keymap_v.md'
	printf '# H1\n' > $md

	assert "$(
		echo "$md" | pbcopy
		nav_keymap_v | bw | compact
	)" "$(
		cat <<-eof
			─────────────────────
			test__nav_keymap_v.md
			─────────────────────
			# H1
		eof
	)"

	rm $md
}

function test__nav_keymap_v__when_pasteboard_is_not_a_file {
	assert "$(
		echo 'not a file' | pbcopy
		nav_keymap_v
	)" "$(
		cat <<-eof
			$(red_bar 'Invalid file path in pasteboard')
		eof
	)"
}

function test__nav_keymap_v__goes_to_folder_and_sets_cursor {
	# Like `n <file>`: cd to the folder and set the cursor, so `nj` continues
	assert "$(
		rm -rf /tmp/test__nav_keymap_v__cursor
		mkdir /tmp/test__nav_keymap_v__cursor
		echo 'one' > /tmp/test__nav_keymap_v__cursor/1.txt
		echo 'two' > /tmp/test__nav_keymap_v__cursor/2.txt
		echo '/tmp/test__nav_keymap_v__cursor/1.txt' | pbcopy
		nav_keymap_v > /dev/null
		pwd
		nav_keymap_j | bw
		cd /tmp && rm -rf /tmp/test__nav_keymap_v__cursor
	)" "$(
		cat <<-eof
		/tmp/test__nav_keymap_v__cursor
		─────
		2.txt
		─────

		two
		eof
	)"
}

function test__nav_keymap_v__with_tilde_path {
	local txt="$HOME/test__nav_keymap_v__tilde.txt"
	echo 'tilde works' > "$txt"

	assert "$(
		# shellcheck disable=SC2088 # Literal ~ is intentional test input (a pasted path)
		echo '~/test__nav_keymap_v__tilde.txt' | pbcopy
		nav_keymap_v | bw | tail -1
	)" 'tilde works'

	rm -f "$txt"
}

function test__nav_keymap_v__with_trailing_metadata {
	local txt='/tmp/test__nav_keymap_v__metadata.txt'
	echo 'metadata works' > "$txt"

	assert "$(
		echo "$txt #jz us-east-1" | pbcopy
		nav_keymap_v | bw | tail -1
	)" 'metadata works'

	rm -f "$txt"
}

function test__nav_keymap_w {
	assert "$(nav_keymap_w > /dev/null; pwd)" "$HOME/Downloads"
}

function test__nav_keymap_y {
	assert "$(
		cd /tmp || return
		nav_keymap_y
		pbpaste
	)" '/tmp'
}

function test__nav_keymap_y__with_file {
	assert "$(
		cd /tmp || return
		nav_keymap_y 'foo.txt'
		pbpaste
	)" '/tmp/foo.txt'
}

function test__nav_keymap_z {
	assert "$(nav_keymap_z > /dev/null; pwd)" "$HOME/GitHub/jasonzhao6/scratch/claude"
}
