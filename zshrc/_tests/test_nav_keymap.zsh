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
}; run_with_filter test__nav_keymap_a

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
}; run_with_filter test__nav_keymap_a__with_filters

function test__nav_keymap_dl {
	assert "$(nav_keymap_dl; pwd)" "$HOME/Downloads"
}; run_with_filter test__nav_keymap_dl

function test__nav_keymap_dm {
	assert "$(nav_keymap_dm; pwd)" "$HOME/Documents"
}; run_with_filter test__nav_keymap_dm

function test__nav_keymap_dt {
	assert "$(nav_keymap_dt; pwd)" "$HOME/Desktop"
}; run_with_filter test__nav_keymap_dt

function test__nav_keymap_h {
	assert "$(nav_keymap_h; pwd)" "$HOME/gh"
}; run_with_filter test__nav_keymap_h

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
}; run_with_filter test__nav_keymap_n

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
}; run_with_filter test__nav_keymap_n__with_filters

function test__nav_keymap_s {
	assert "$(nav_keymap_s; pwd)" "$HOME/gh/scratch"
}; run_with_filter test__nav_keymap_s

function test__nav_keymap_u {
	assert "$(
		rm -rf /tmp/_nav_keymap_u
		mkdir -p /tmp/_nav_keymap_u/1
		cd /tmp/_nav_keymap_u/1 || return
		nav_keymap_u
		pwd
		rm -rf /tmp/_nav_keymap_u
	)" '/tmp/_nav_keymap_u'
}; run_with_filter test__nav_keymap_u

function test__nav_keymap_uu {
	assert "$(
		rm -rf /tmp/_nav_keymap_uu
		mkdir -p /tmp/_nav_keymap_uu/1/2
		cd /tmp/_nav_keymap_uu/1/2 || return
		nav_keymap_uu
		pwd
		rm -rf /tmp/_nav_keymap_uu
	)" '/tmp/_nav_keymap_uu'
}; run_with_filter test__nav_keymap_uu

function test__nav_keymap_uuu {
	assert "$(
		rm -rf /tmp/_nav_keymap_uuu
		mkdir -p /tmp/_nav_keymap_uuu/1/2/3
		cd /tmp/_nav_keymap_uuu/1/2/3 || return
		nav_keymap_uuu
		pwd
		rm -rf /tmp/_nav_keymap_uuu
	)" '/tmp/_nav_keymap_uuu'
}; run_with_filter test__nav_keymap_uuu

function test__nav_keymap_v__with_dir {
	assert "$(nav_keymap_v ~/Documents 2>&1; pwd)" "$HOME/Documents"
}; run_with_filter test__nav_keymap_v__with_dir

function test__nav_keymap_v__with_file {
	assert "$(nav_keymap_v ~/Documents/.zshrc 2>&1; pwd)" "$HOME/Documents"
}; run_with_filter test__nav_keymap_v__with_file
