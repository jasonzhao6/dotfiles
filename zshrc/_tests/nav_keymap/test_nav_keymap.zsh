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
		cd /tmp
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
		echo "$HOME/Documents" > "$NAV_YANK_FILE"
		nav_keymap_p > /dev/null
		pwd
	)" "$HOME/Documents"
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
		nav_keymap_t > /dev/null
		pwd
	)" "$HOME/Documents"
}

function test__nav_keymap_t__with_file {
	assert "$(
		touch /tmp/test__nav_keymap_t__with_file
		echo '/tmp/test__nav_keymap_t__with_file' | pbcopy
		nav_keymap_t > /dev/null
		pwd
		rm -f /tmp/test__nav_keymap_t__with_file
	)" '/tmp'
}

function test__nav_keymap_t__with_invalid_path {
	assert "$(
		echo 'does not exist' | pbcopy
		nav_keymap_t
	)" "$(red_bar 'Invalid path in pasteboard')"
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

function test__nav_keymap_v {
	assert "$(nav_keymap_v > /dev/null; pwd)" "$HOME/Desktop"
}

function test__nav_keymap_w {
	assert "$(nav_keymap_w > /dev/null; pwd)" "$HOME/Downloads"
}

function test__nav_keymap_x {
	assert "$(nav_keymap_x > /dev/null; pwd)" "$HOME/GitHub/jasonzhao6/excalidraw"
}

function test__nav_keymap_y {
	assert "$(
		cd "$HOME/Documents" || return
		rm -f "$NAV_YANK_FILE"
		nav_keymap_y
		cat "$NAV_YANK_FILE"
	)" "$HOME/Documents"
}

function test__nav_keymap_z {
	assert "$(nav_keymap_z > /dev/null; pwd)" "$NAV_CLAUDE_PLANS_DIR"
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
	)" "$(red_bar 'No plans found')"
}
