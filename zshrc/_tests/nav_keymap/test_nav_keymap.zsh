function test__nav_keymap {
	assert "$(
		local show_this_help; show_this_help=$(nav_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
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
		ZSHRC_UNDER_TESTING=1 nav_keymap 2.txt | bw
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
		ZSHRC_UNDER_TESTING=1 nav_keymap_j | bw
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
		ZSHRC_UNDER_TESTING=1 nav_keymap test__nav_keymap__file_cd/note.txt > /dev/null
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
		ZSHRC_UNDER_TESTING=1 nav_keymap /tmp/test__nav_keymap__file_cd_nj/1.txt > /dev/null
		ZSHRC_UNDER_TESTING=1 nav_keymap_j | bw
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
		ZSHRC_UNDER_TESTING=1 nav_keymap 1.txt > /dev/null
		ZSHRC_UNDER_TESTING=1 nav_keymap_j | bw
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
		ZSHRC_UNDER_TESTING=1 nav_keymap /tmp/test__nav_keymap__hidden/.1.hidden > /dev/null
		ZSHRC_UNDER_TESTING=1 nav_keymap_j | bw
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
	printf '# One\n\n## Two\n\n###### Six\n' > $md

	local output; output=$(ZSHRC_UNDER_TESTING=1 nav_keymap $md)
	local plain; plain=$(echo "$output" | bw)

	# Headings render as `#` prefixes at every level, incl. the H1 banner
	assert "$([[ $plain == *'# One'* && $plain == *'## Two'* && $plain == *'###### Six'* ]] && echo 1)" '1'

	# Headings are magenta (35)
	assert "$([[ $output =~ $'\e\\[35m# One' ]] && echo 1)" '1'
	assert "$([[ $output =~ $'\e\\[35m## ' ]] && echo 1)" '1'

	# Blocks are separated by single blank lines, never runs of them
	assert "$([[ $plain != *$'\n\n\n'* ]] && echo 1)" '1'

	rm $md
}

function test__nav_keymap__renders_md_link_labels_cyan {
	local md='/tmp/test__nav_keymap__raw_md_links.md'
	printf 'a [link](https://example.com) here, wrapped by filler words pushing this [long link label across the eighty column boundary](https://example.com/foo) end\n' > $md

	local output; output=$(ZSHRC_UNDER_TESTING=1 nav_keymap $md)

	# Link labels are cyan (36), including a wrapped label's continuation line
	assert "$([[ $output =~ $'\e\\[36mlink' ]] && echo 1)" '1'
	assert "$([[ $output =~ $'\e\\[36meighty column boundary' ]] && echo 1)" '1'

	# OSC 8 hyperlink escapes are kept
	assert "$([[ $output == *$'\e]8;;https://example.com/'* ]] && echo 1)" '1'

	rm $md
}

function test__nav_keymap__when_specifying_an_arbitrary_txt_file {
	local txt='/tmp/test__nav_keymap__arbitrary_txt.txt'
	echo 'hello' > $txt

	assert "$(
		ZSHRC_UNDER_TESTING=1 nav_keymap $txt | bw
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

function test__nav_keymap_b {
	assert "$(nav_keymap_b > /dev/null; pwd)" "$HOME/Desktop"
}

function test__nav_keymap_d {
	assert "$(nav_keymap_d > /dev/null; pwd)" "$HOME/GitHub/jasonzhao6/dotfiles"
}

function test__nav_keymap_e {
	assert "$(
		rm -rf /tmp/test__nav_keymap_e
		mkdir /tmp/test__nav_keymap_e
		cd /tmp/test__nav_keymap_e || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_e | bw
		rm -rf /tmp/test__nav_keymap_e
	)" "$(
		cat <<-eof
		     1	1.log
		     2	2.log
		     3	3.txt
		eof
	)"
}

function test__nav_keymap_e__with_filters {
	assert "$(
		rm -rf /tmp/test__nav_keymap_e
		mkdir /tmp/test__nav_keymap_e
		cd /tmp/test__nav_keymap_e || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_e -1 log | bw
		rm -rf /tmp/test__nav_keymap_e
	)" "$(
		cat <<-eof
		     1	2.log
		eof
	)"
}

function test__nav_keymap_ee {
	assert "$(
		rm -rf /tmp/test__nav_keymap_ee
		mkdir /tmp/test__nav_keymap_ee
		cd /tmp/test__nav_keymap_ee || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_ee | bw
		rm -rf /tmp/test__nav_keymap_ee
	)" "$(
		cat <<-eof
		     1	.2.hidden
		     2	.3.hidden
		eof
	)"
}

function test__nav_keymap_ee__with_filters {
	assert "$(
		rm -rf /tmp/test__nav_keymap_ee
		mkdir /tmp/test__nav_keymap_ee
		cd /tmp/test__nav_keymap_ee || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_ee -3 hidden | bw
		rm -rf /tmp/test__nav_keymap_ee
	)" "$(
		cat <<-eof
		     1	.2.hidden
		eof
	)"
}

function test__nav_keymap_f {
	assert "$(
		rm -rf /tmp/test__nav_keymap_f
		mkdir /tmp/test__nav_keymap_f
		cd /tmp/test__nav_keymap_f || return
		dd if=/dev/zero of=small.txt bs=1 count=100 2>/dev/null
		dd if=/dev/zero of=big.txt bs=1 count=200 2>/dev/null
		local output; output=$(nav_keymap_f)
		echo "$output" | head -1 | awk '{print $NF}'
		echo "$output" | tail -1 | awk '{print $NF}'
		rm -rf /tmp/test__nav_keymap_f
	)" "$(
		cat <<-eof
			small.txt
			big.txt
		eof
	)"
}

function test__nav_keymap_g {
	assert "$(
		rm -rf /tmp/test__nav_keymap_g
		mkdir -p /tmp/test__nav_keymap_g/sub1
		mkdir -p /tmp/test__nav_keymap_g/sub2
		cd /tmp/test__nav_keymap_g || return
		dd if=/dev/zero of=sub1/f.txt bs=1024 count=1 2>/dev/null
		local output; output=$(nav_keymap_g)
		# du -hd1 returns: sub1, sub2, and . (3 lines total)
		echo "$output" | wc -l | tr -d ' '
		rm -rf /tmp/test__nav_keymap_g
	)" '3'
}

function test__nav_keymap_h {
	assert "$(nav_keymap_h > /dev/null; pwd)" "$HOME/GitHub"
}

function test__nav_keymap_i {
	assert "$(nav_keymap_i > /dev/null; pwd)" "$HOME/GitHub/jasonzhao6/excalidraw"
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
		(ZSHRC_UNDER_TESTING=1; nav_keymap_j; nav_keymap_j; nav_keymap_j) | bw
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
		echo '# Heading' > note.md
		nav_keymap_n > /dev/null
		# nav_helpers_render_file output differs from cat; just check it does not error
		# and that the file name is shown
		nav_keymap_j 2>/dev/null | bw | grep --count '^note.md$'
		rm -rf /tmp/test__nav_keymap_j
	)" '1'
}

function test__nav_keymap_j__cats_log {
	assert "$(
		rm -rf /tmp/test__nav_keymap_j
		mkdir /tmp/test__nav_keymap_j
		cd /tmp/test__nav_keymap_j || return
		echo 'logged' > app.log
		nav_keymap_n > /dev/null
		ZSHRC_UNDER_TESTING=1 nav_keymap_j | bw
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
		ZSHRC_UNDER_TESTING=1 nav_keymap_j | bw
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
		ZSHRC_UNDER_TESTING=1 nav_keymap_j | bw  # should show 1.txt again
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
		# shellcheck disable=SC2034 # ZSHRC_UNDER_TESTING is the global test flag; read by the sourced keymap code, not here
		(ZSHRC_UNDER_TESTING=1; nav_keymap_k; nav_keymap_k; nav_keymap_k) | bw
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
		ZSHRC_UNDER_TESTING=1 nav_keymap_k | bw  # cursor=2 → 2.txt
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

function test__nav_keymap_o {
	assert "$(
		rm -rf /tmp/test__nav_keymap_o
		mkdir /tmp/test__nav_keymap_o
		cd /tmp/test__nav_keymap_o || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_o | bw
		rm -rf /tmp/test__nav_keymap_o
	)" "$(
		cat <<-eof
		     1	1/
		     2	2/
		     3	3/
		eof
	)"
}

function test__nav_keymap_o__with_filters {
	assert "$(
		rm -rf /tmp/test__nav_keymap_o
		mkdir /tmp/test__nav_keymap_o
		cd /tmp/test__nav_keymap_o || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_o -1 | bw
		rm -rf /tmp/test__nav_keymap_o
	)" "$(
		cat <<-eof
		     1	2/
		     2	3/
		eof
	)"
}

function test__nav_keymap_oo {
	assert "$(
		rm -rf /tmp/test__nav_keymap_oo
		mkdir /tmp/test__nav_keymap_oo
		cd /tmp/test__nav_keymap_oo || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_oo | bw
		rm -rf /tmp/test__nav_keymap_oo
	)" "$(
		cat <<-eof
		     1	.1.hidden/
		eof
	)"
}

function test__nav_keymap_oo__with_filters {
	assert "$(
		rm -rf /tmp/test__nav_keymap_oo
		mkdir /tmp/test__nav_keymap_oo
		cd /tmp/test__nav_keymap_oo || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		nav_keymap_oo -1 hidden | bw
		rm -rf /tmp/test__nav_keymap_oo
	)" ''
}

function test__nav_keymap_p {
	assert "$(
		echo "$HOME/Documents" > "$NAV_MRU_FILE"
		nav_keymap_p > /dev/null
		pwd
	)" "$HOME/Documents"
}

function test__nav_keymap_p__when_empty {
	assert "$(
		rm -f "$NAV_MRU_FILE"
		nav_keymap_p
	)" "$(red_bar 'MRU queue is empty')"
}

function test__nav_keymap_p__uses_head_of_queue {
	assert "$(
		printf '%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" > "$NAV_MRU_FILE"
		nav_keymap_p > /dev/null
		pwd
	)" "$HOME/Documents"
}

function test__nav_keymap_q {
	assert "$(
		printf '%s\n%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" > "$NAV_MRU_FILE"
		nav_keymap_q | bw
	)" "$(
		cat <<-eof
		     1	$HOME/Documents
		     2	$HOME/Downloads
		     3	$HOME/Desktop
		eof
	)"
}

function test__nav_keymap_q__with_filters {
	assert "$(
		printf '%s\n%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" > "$NAV_MRU_FILE"
		nav_keymap_q Do | bw
	)" "$(
		cat <<-eof
		     1	$HOME/Documents
		     2	$HOME/Downloads
		eof
	)"
}

function test__nav_keymap_q__single_entry_cds {
	assert "$(
		printf '%s\n' "$HOME/Downloads" > "$NAV_MRU_FILE"
		nav_keymap_q > /dev/null
		pwd
	)" "$HOME/Downloads"
}

function test__nav_keymap_q__single_match_cds {
	assert "$(
		printf '%s\n%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" > "$NAV_MRU_FILE"
		nav_keymap_q Down > /dev/null
		pwd
	)" "$HOME/Downloads"
}

function test__nav_keymap_q__single_match_moves_to_head {
	assert "$(
		printf '%s\n%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" > "$NAV_MRU_FILE"
		nav_keymap_q Down > /dev/null
		head -1 "$NAV_MRU_FILE"
	)" "$HOME/Downloads"
}

function test__nav_keymap_q__empty {
	assert "$(
		rm -f "$NAV_MRU_FILE"
		nav_keymap_q
	)" "$(red_bar 'MRU queue is empty')"
}

function test__nav_keymap_q__prunes_missing_dirs {
	local gone=/tmp/test__nav_keymap_q__prunes_missing_dirs
	rm -rf "$gone"

	printf '%s\n%s\n%s\n' "$HOME/Documents" "$gone" "$HOME/Downloads" > "$NAV_MRU_FILE"

	# Missing dir is dropped from the listing
	assert "$(nav_keymap_q | bw)" "$(
		cat <<-eof
		     1	$HOME/Documents
		     2	$HOME/Downloads
		eof
	)"

	# Missing dir is removed from the MRU file
	assert "$(cat "$NAV_MRU_FILE")" "$(printf '%s\n%s' "$HOME/Documents" "$HOME/Downloads")"
}

function test__nav_keymap_q__prunes_to_empty {
	local gone=/tmp/test__nav_keymap_q__prunes_to_empty
	rm -rf "$gone"

	assert "$(
		printf '%s\n' "$gone" > "$NAV_MRU_FILE"
		nav_keymap_q
	)" "$(red_bar 'MRU queue is empty')"
}

function test__nav_keymap_qk {
	# Wrap in a subshell so the re-list's in-memory `ARGS_HISTORY` mutation does
	# not leak into sibling tests
	assert "$(
		printf '%s\n%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" > "$NAV_MRU_FILE"
		nav_keymap_qk 2 > /dev/null
		cat "$NAV_MRU_FILE" # Only the top N entries remain
	)" "$(printf '%s\n%s' "$HOME/Documents" "$HOME/Downloads")"
}

function test__nav_keymap_qk__relists {
	assert "$(
		printf '%s\n%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" > "$NAV_MRU_FILE"
		nav_keymap_qk 2 | bw
	)" "$(
		cat <<-eof
		     1	$HOME/Documents
		     2	$HOME/Downloads
		eof
	)"
}

function test__nav_keymap_qk__count_exceeds_size {
	assert "$(
		printf '%s\n%s\n' "$HOME/Documents" "$HOME/Downloads" > "$NAV_MRU_FILE"
		nav_keymap_qk 9 > /dev/null
		cat "$NAV_MRU_FILE" # Keeping more than exist is a safe no-op
	)" "$(printf '%s\n%s' "$HOME/Documents" "$HOME/Downloads")"
}

function test__nav_keymap_qk__usage_error {
	assert "$(
		printf '%s\n' "$HOME/Documents" > "$NAV_MRU_FILE"
		nav_keymap_qk
	)" "$(red_bar 'Usage: nqk <count>')"
}

function test__nav_keymap_qk__empty {
	assert "$(
		rm -f "$NAV_MRU_FILE"
		nav_keymap_qk 2
	)" "$(red_bar 'MRU queue is empty')"
}

function test__nav_keymap_qq {
	assert "$(
		echo "$HOME/Documents" > "$NAV_MRU_FILE"
		nav_keymap_qq
		[[ ! -f "$NAV_MRU_FILE" ]] && echo 'cleared'
	)" 'cleared'
}

function test__nav_keymap_r {
	assert "$(
		rm -rf /tmp/test__nav_keymap_r
		mkdir /tmp/test__nav_keymap_r
		cd /tmp/test__nav_keymap_r || return
		touch -t 202301010000 old.txt
		touch -t 202401010000 new.txt
		local output; output=$(nav_keymap_r)
		echo "$output" | head -1 | awk '{print $NF}'
		echo "$output" | tail -1 | awk '{print $NF}'
		rm -rf /tmp/test__nav_keymap_r
	)" "$(
		cat <<-eof
			old.txt
			new.txt
		eof
	)"
}

function test__nav_keymap_s {
	assert "$(nav_keymap_s > /dev/null; pwd)" "$HOME/GitHub/jasonzhao6/scratch"
}

function test__nav_keymap_t__with_dir {
	assert "$(
		echo "$HOME/Documents" | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_t > /dev/null
		pwd
	)" "$HOME/Documents"
}

function test__nav_keymap_t__with_file {
	assert "$(
		touch /tmp/test__nav_keymap_t__with_file
		echo '/tmp/test__nav_keymap_t__with_file' | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_t > /dev/null
		pwd
		rm -f /tmp/test__nav_keymap_t__with_file
	)" '/tmp'
}

function test__nav_keymap_t__with_invalid_path {
	assert "$(
		echo 'does not exist' | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_t
	)" "$(red_bar 'Invalid path in pasteboard')"
}

function test__nav_keymap_t__with_tilde_dir {
	assert "$(
		# shellcheck disable=SC2088 # Literal ~ is intentional test input (a pasted path)
		echo '~/Documents' | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_t > /dev/null
		pwd
	)" "$HOME/Documents"
}

function test__nav_keymap_t__with_tilde_file {
	assert "$(
		touch "$HOME/test__nav_keymap_t__with_tilde_file"
		# shellcheck disable=SC2088 # Literal ~ is intentional test input (a pasted path)
		echo '~/test__nav_keymap_t__with_tilde_file' | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_t > /dev/null
		pwd
		rm -f "$HOME/test__nav_keymap_t__with_tilde_file"
	)" "$HOME"
}

function test__nav_keymap_t__with_trailing_metadata {
	assert "$(
		local repo=/tmp/test__nav_keymap_t__with_trailing_metadata
		rm -rf "$repo"
		mkdir -p "$repo"
		echo "$repo #jz mq01-qa.team-transaction-engine-dev us-east-1" | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_t > /dev/null
		pwd
		rm -rf "$repo"
	)" '/tmp/test__nav_keymap_t__with_trailing_metadata'
}

function test__nav_keymap_t__with_path_containing_space_and_metadata {
	assert "$(
		local repo='/tmp/test__nav_keymap_t hello world #eou'
		rm -rf "$repo"
		mkdir -p "$repo"
		echo "$repo mq01-qa.team-transaction-engine-dev us-east-1" | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_t > /dev/null
		pwd
		rm -rf "$repo"
	)" '/tmp/test__nav_keymap_t hello world #eou'
}

function test__nav_keymap_t__with_tilde_and_metadata {
	assert "$(
		# shellcheck disable=SC2088 # Literal ~ is intentional test input (a pasted path)
		echo '~/Documents #jz mq01-qa.team-transaction-engine-dev us-east-1' | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_t > /dev/null
		pwd
	)" "$HOME/Documents"
}

function test__nav_keymap_t__with_file_and_metadata {
	assert "$(
		touch /tmp/test__nav_keymap_t__with_file_and_metadata
		echo '/tmp/test__nav_keymap_t__with_file_and_metadata #jz us-east-1' | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_t > /dev/null
		pwd
		rm -f /tmp/test__nav_keymap_t__with_file_and_metadata
	)" '/tmp'
}

function test__nav_keymap_t__with_surrounding_whitespace {
	# The resolver strips surrounding whitespace before validating the path
	assert "$(
		touch /tmp/test__nav_keymap_t__whitespace.txt
		printf '  /tmp/test__nav_keymap_t__whitespace.txt  ' | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_t > /dev/null
		pwd
		rm -f /tmp/test__nav_keymap_t__whitespace.txt
	)" '/tmp'
}

function test__nav_keymap_t__with_file_sets_cursor {
	# The cursor lands on the pasted file, so `nx` renders it
	assert "$(
		rm -rf /tmp/test__nav_keymap_t__cursor
		mkdir /tmp/test__nav_keymap_t__cursor
		echo 'one' > /tmp/test__nav_keymap_t__cursor/1.txt
		echo 'two' > /tmp/test__nav_keymap_t__cursor/2.txt
		echo '/tmp/test__nav_keymap_t__cursor/2.txt' | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_t > /dev/null
		ZSHRC_UNDER_TESTING=1 nav_keymap_x | bw
		cd /tmp && rm -rf /tmp/test__nav_keymap_t__cursor
	)" "$(
		cat <<-eof
		─────
		2.txt
		─────

		two
		eof
	)"
}

function test__nav_keymap_t__with_hidden_file_sets_cursor {
	# A pasted hidden file gets the hidden listing, so the cursor can still be set
	assert "$(
		rm -rf /tmp/test__nav_keymap_t__hidden
		mkdir /tmp/test__nav_keymap_t__hidden
		echo 'one' > /tmp/test__nav_keymap_t__hidden/.1.hidden
		echo 'two' > /tmp/test__nav_keymap_t__hidden/.2.hidden
		echo '/tmp/test__nav_keymap_t__hidden/.2.hidden' | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_t > /dev/null
		ZSHRC_UNDER_TESTING=1 nav_keymap_x | bw
		cd /tmp && rm -rf /tmp/test__nav_keymap_t__hidden
	)" "$(
		cat <<-eof
		─────────
		.2.hidden
		─────────

		two
		eof
	)"
}

function test__nav_keymap_tt {
	assert "$(
		cd /tmp || return
		nav_keymap_tt
		pbpaste
	)" '/tmp'
}

function test__nav_keymap_tt__with_file {
	assert "$(
		cd /tmp || return
		nav_keymap_tt 'foo.txt'
		pbpaste
	)" '/tmp/foo.txt'
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

function test__nav_keymap_uu {
	assert "$(
		rm -rf /tmp/_nav_keymap_uu
		mkdir -p /tmp/_nav_keymap_uu/1/2
		cd /tmp/_nav_keymap_uu/1/2 || return
		nav_keymap_uu > /dev/null
		pwd
		rm -rf /tmp/_nav_keymap_uu
	)" '/tmp/_nav_keymap_uu'
}

function test__nav_keymap_uuu {
	assert "$(
		rm -rf /tmp/_nav_keymap_uuu
		mkdir -p /tmp/_nav_keymap_uuu/1/2/3
		cd /tmp/_nav_keymap_uuu/1/2/3 || return
		nav_keymap_uuu > /dev/null
		pwd
		rm -rf /tmp/_nav_keymap_uuu
	)" '/tmp/_nav_keymap_uuu'
}

function test__nav_keymap_v__renders_pasteboard_file {
	local md='/tmp/test__nav_keymap_v.md'
	printf '# H1\n' > $md

	assert "$(
		echo "$md" | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_v | bw | compact
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
		ZSHRC_UNDER_TESTING=1 nav_keymap_v
	)" "$(
		cat <<-eof
			$(red_bar 'Invalid file path in pasteboard')
		eof
	)"
}

function test__nav_keymap_v__goes_to_folder_and_sets_cursor {
	# Like \`n <file>\`: cd to the folder and set the cursor, so \`nj\` continues
	assert "$(
		rm -rf /tmp/test__nav_keymap_v__cursor
		mkdir /tmp/test__nav_keymap_v__cursor
		echo 'one' > /tmp/test__nav_keymap_v__cursor/1.txt
		echo 'two' > /tmp/test__nav_keymap_v__cursor/2.txt
		echo '/tmp/test__nav_keymap_v__cursor/1.txt' | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_v > /dev/null
		pwd
		ZSHRC_UNDER_TESTING=1 nav_keymap_j | bw
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
		ZSHRC_UNDER_TESTING=1 nav_keymap_v | bw | tail -1
	)" 'tilde works'

	rm -f "$txt"
}

function test__nav_keymap_v__with_trailing_metadata {
	local txt='/tmp/test__nav_keymap_v__metadata.txt'
	echo 'metadata works' > "$txt"

	assert "$(
		echo "$txt #jz us-east-1" | pbcopy
		ZSHRC_UNDER_TESTING=1 nav_keymap_v | bw | tail -1
	)" 'metadata works'

	rm -f "$txt"
}

function test__nav_keymap_w {
	assert "$(nav_keymap_w > /dev/null; pwd)" "$HOME/Downloads"
}

function test__nav_keymap_x {
	assert "$(
		rm -rf /tmp/test__nav_keymap_x
		mkdir /tmp/test__nav_keymap_x
		cd /tmp/test__nav_keymap_x || return
		echo 'one' > 1.txt
		echo 'two' > 2.txt
		nav_keymap_n > /dev/null
		nav_keymap_j > /dev/null  # cursor=1
		ZSHRC_UNDER_TESTING=1 nav_keymap_x | bw  # reprint 1.txt without moving cursor
		rm -rf /tmp/test__nav_keymap_x
	)" "$(
		cat <<-eof
		─────
		1.txt
		─────

		one
		eof
	)"
}

function test__nav_keymap_x__on_fresh_list {
	assert "$(
		rm -rf /tmp/test__nav_keymap_x
		mkdir /tmp/test__nav_keymap_x
		cd /tmp/test__nav_keymap_x || return
		echo 'one' > 1.txt
		nav_keymap_n > /dev/null  # cursor=0, fresh list
		ZSHRC_UNDER_TESTING=1 nav_keymap_x | bw  # should print first file like nj
		rm -rf /tmp/test__nav_keymap_x
	)" "$(
		cat <<-eof
		─────
		1.txt
		─────

		one
		eof
	)"
}

function test__nav_keymap_x__when_empty {
	assert "$(
		rm -rf /tmp/test__nav_keymap_x
		mkdir /tmp/test__nav_keymap_x
		cd /tmp/test__nav_keymap_x || return
		nav_keymap_n > /dev/null
		nav_keymap_x | bw
		rm -rf /tmp/test__nav_keymap_x
	)" "$(red_bar 'No current file in the list' | bw)"
}

function test__nav_keymap_x__reflects_updated_content {
	assert "$(
		rm -rf /tmp/test__nav_keymap_x
		mkdir /tmp/test__nav_keymap_x
		cd /tmp/test__nav_keymap_x || return
		echo 'before' > 1.txt
		nav_keymap_n > /dev/null
		nav_keymap_j > /dev/null
		echo 'after' > 1.txt
		ZSHRC_UNDER_TESTING=1 nav_keymap_x | bw
		rm -rf /tmp/test__nav_keymap_x
	)" "$(
		cat <<-eof
		─────
		1.txt
		─────

		after
		eof
	)"
}

function test__nav_keymap_y {
	assert "$(
		rm -f "$NAV_MRU_FILE"
		cd "$HOME/Documents" || return
		nav_keymap_y
		head -1 "$NAV_MRU_FILE"
	)" "$HOME/Documents"
}

function test__nav_keymap_y__prepends_to_queue {
	assert "$(
		rm -f "$NAV_MRU_FILE"
		cd "$HOME/Downloads" || return
		nav_keymap_y
		cd "$HOME/Documents" || return
		nav_keymap_y
		cat "$NAV_MRU_FILE"
	)" "$(printf '%s\n%s' "$HOME/Documents" "$HOME/Downloads")"
}

function test__nav_keymap_y__dedupes_existing_entry {
	assert "$(
		rm -f "$NAV_MRU_FILE"
		cd "$HOME/Downloads" || return
		nav_keymap_y
		cd "$HOME/Documents" || return
		nav_keymap_y
		cd "$HOME/Downloads" || return
		nav_keymap_y
		cat "$NAV_MRU_FILE"
	)" "$(printf '%s\n%s' "$HOME/Downloads" "$HOME/Documents")"
}

function test__nav_keymap_z {
	assert "$(nav_keymap_z > /dev/null; pwd)" "$NAV_CLAUDE_DIR"
}

function test__nav_keymap_zz__goes_to_plans_and_sets_cursor {
	local tmp_dir; tmp_dir=$(mktemp -d)

	# The cursor lands on the latest plan (not the first listed), so `nx` rerenders it
	assert "$(
		NAV_CLAUDE_PLANS_DIR=$tmp_dir
		printf '# Old\n' > "$tmp_dir/a-old.md"
		touch -t 202501010000 "$tmp_dir/a-old.md"
		printf '# New\n' > "$tmp_dir/z-new.md"

		ZSHRC_UNDER_TESTING=1 nav_keymap_zz > /dev/null
		pwd
		ZSHRC_UNDER_TESTING=1 nav_keymap_x | bw | compact | head -2 | tail -1
	)" "$(printf '%s\n%s' "$tmp_dir" 'z-new.md')"

	rm -rf "$tmp_dir"
}

function test__nav_keymap_zz__with_no_plans {
	assert "$(
		local tmp_dir; tmp_dir=$(mktemp -d)
		local orig=$NAV_CLAUDE_PLANS_DIR
		NAV_CLAUDE_PLANS_DIR=$tmp_dir

		# Empty dir should show error
		nav_keymap_zz 2>/dev/null

		rm -rf "$tmp_dir"
		NAV_CLAUDE_PLANS_DIR=$orig
	)" "$(red_bar 'No plans')"
}
