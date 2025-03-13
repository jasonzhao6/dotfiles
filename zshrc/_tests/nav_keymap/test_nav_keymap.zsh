function test__nav_keymap {
	assert "$(
		local show_this_help; show_this_help=$(nav_keymap | grep help | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $NAV_ALIAS +# Show this help$" ]] && echo 1
	)" '1'
}; run_with_filter test__nav_keymap

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
}; run_with_filter test__nav_keymap__when_specifying_a_directory_instead_of_key

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

function test__nav_keymap_d {
	assert "$(nav_keymap_d > /dev/null; pwd)" "$HOME/github/jasonzhao6/dotfiles"
}; run_with_filter test__nav_keymap_d

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
}; run_with_filter test__nav_keymap_e

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
}; run_with_filter test__nav_keymap_e__with_filters

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
}; run_with_filter test__nav_keymap_ee

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
}; run_with_filter test__nav_keymap_ee__with_filters

function test__nav_keymap_h {
	assert "$(nav_keymap_h > /dev/null; pwd)" "$HOME/github"
}; run_with_filter test__nav_keymap_h

function test__nav_keymap_m {
	assert "$(nav_keymap_m > /dev/null; pwd)" "$HOME/Documents"
}; run_with_filter test__nav_keymap_m

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
}; run_with_filter test__nav_keymap_o

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
}; run_with_filter test__nav_keymap_o__with_filters

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
}; run_with_filter test__nav_keymap_oo

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
}; run_with_filter test__nav_keymap_oo__with_filters

function test__nav_keymap_s {
	assert "$(nav_keymap_s > /dev/null; pwd)" "$HOME/github/jasonzhao6/scratch"
}; run_with_filter test__nav_keymap_s

function test__nav_keymap_t__with_dir {
	assert "$(
		echo "$HOME/Documents" | pbcopy
		nav_keymap_t > /dev/null
		pwd
	)" "$HOME/Documents"
}; run_with_filter test__nav_keymap_t__with_dir

function test__nav_keymap_t__with_file {
	assert "$(
		touch /tmp/test__nav_keymap_t__with_file
		echo '/tmp/test__nav_keymap_t__with_file' | pbcopy
		nav_keymap_t > /dev/null
		pwd
		rm -f /tmp/test__nav_keymap_t__with_file
	)" '/tmp'
}; run_with_filter test__nav_keymap_t__with_file

function test__nav_keymap_t__with_invalid_path {
	assert "$(
		echo 'does not exist' | pbcopy
		nav_keymap_t
	)" "$(echo; red_bar 'Invalid path in pasteboard')"
}; run_with_filter test__nav_keymap_t__with_invalid_path

function test__nav_keymap_u {
	assert "$(
		rm -rf /tmp/_nav_keymap_u
		mkdir -p /tmp/_nav_keymap_u/1
		cd /tmp/_nav_keymap_u/1 || return
		nav_keymap_u > /dev/null
		pwd
		rm -rf /tmp/_nav_keymap_u
	)" '/tmp/_nav_keymap_u'
}; run_with_filter test__nav_keymap_u

function test__nav_keymap_uu {
	assert "$(
		rm -rf /tmp/_nav_keymap_uu
		mkdir -p /tmp/_nav_keymap_uu/1/2
		cd /tmp/_nav_keymap_uu/1/2 || return
		nav_keymap_uu > /dev/null
		pwd
		rm -rf /tmp/_nav_keymap_uu
	)" '/tmp/_nav_keymap_uu'
}; run_with_filter test__nav_keymap_uu

function test__nav_keymap_uuu {
	assert "$(
		rm -rf /tmp/_nav_keymap_uuu
		mkdir -p /tmp/_nav_keymap_uuu/1/2/3
		cd /tmp/_nav_keymap_uuu/1/2/3 || return
		nav_keymap_uuu > /dev/null
		pwd
		rm -rf /tmp/_nav_keymap_uuu
	)" '/tmp/_nav_keymap_uuu'
}; run_with_filter test__nav_keymap_uuu

function test__nav_keymap_v {
	assert "$(nav_keymap_v > /dev/null; pwd)" "$HOME/Desktop"
}; run_with_filter test__nav_keymap_v

function test__nav_keymap_w {
	assert "$(nav_keymap_w > /dev/null; pwd)" "$HOME/Downloads"
}; run_with_filter test__nav_keymap_w
