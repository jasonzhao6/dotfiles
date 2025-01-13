
# Skip: Cannot test b/c requires querying github
# function other_keymap_f__for_gh

function test__f__for_tf {
	assert "$(
		local home=$HOME
		local pwd=$PWD
		HOME="/tmp/test__f"
		mkdir -p $HOME/project/module/.terraform

		touch $HOME/project/main.tf
		touch $HOME/project/module/main.tf
		touch $HOME/project/module/.terraform/main.tf

		cd $HOME || return
		f tf

		rm -rf $HOME
		HOME=$home
		cd "$pwd" || return
	)" "$(
		cat <<-eof
		     1	~/project
		     2	~/project/module
		eof
	)"
}; run_with_filter test__f__for_tf


# Skip: Not testing b/c requires network call
# function other_keymap_dd

function test__dd {
	assert "$(
		DD_CLEAR_TERMINAL=0
		DD_DUMP_DIR="/tmp/test__dd"
		rm -rf $DD_DUMP_DIR

		echo '$' | pbcopy
		dd
		ls -l $DD_DUMP_DIR | wc -l
		cat $DD_DUMP_DIR/*

		dd_init
		rm -rf $DD_DUMP_DIR
	)" "$(
		cat <<-eof
			       2
			$
		eof
	)"
}; run_with_filter test__dd

function test__dd__when_dumping_same_pasteboard_twice {
	assert "$(
		DD_CLEAR_TERMINAL=0
		DD_DUMP_DIR="/tmp/test__dd"
		rm -rf $DD_DUMP_DIR

		echo '$' | pbcopy
		dd
		dd
		ls -l $DD_DUMP_DIR | wc -l
		cat $DD_DUMP_DIR/*

		dd_init
		rm -rf $DD_DUMP_DIR
	)" "$(
		cat <<-eof
			       2
			$
		eof
	)"
}; run_with_filter test__dd__when_dumping_same_pasteboard_twice

function test__dd__when_dumping_two_different_pasteboards {
	assert "$(
		DD_CLEAR_TERMINAL=0
		DD_DUMP_DIR="/tmp/test__dd"
		rm -rf $DD_DUMP_DIR

		printf "pasteboard 1\n$\n" | pbcopy
		dd
		printf "pasteboard 2\n$\n" | pbcopy
		dd
		ls -l $DD_DUMP_DIR | wc -l
		cat $DD_DUMP_DIR/*

		dd_init
		rm -rf $DD_DUMP_DIR
	)" "$(
		cat <<-eof
			       3
			pasteboard 1
			$
			pasteboard 2
			$
		eof
	)"
}; run_with_filter test__dd__when_dumping_two_different_pasteboards

function test__dd__when_not_terminal_output {
	assert "$(
		# shellcheck disable=SC2034
		DD_CLEAR_TERMINAL=0
		# shellcheck disable=SC2030
		DD_DUMP_DIR="/tmp/test__dd"
		rm -rf $DD_DUMP_DIR

		echo 'not terminal output' | pbcopy
		dd
		ls -l $DD_DUMP_DIR | wc -l

		dd_init
	)" '       1'
}; run_with_filter test__dd__when_not_terminal_output

function test__ddd {
	# shellcheck disable=SC2031
	assert "$(ddd; pwd)" "$DD_DUMP_DIR"
}; run_with_filter test__ddd

function test__ddc {
	assert "$(
		DD_DUMP_DIR="/tmp/test__dd"
		mkdir -p $DD_DUMP_DIR

		ddc
		[[ -e $DD_DUMP_DIR ]] && echo present || echo absent

		dd_init
	)" 'absent'
}; run_with_filter test__ddc


# Skip: Not interesting b/c it has its own specs
# function other_keymap_pp

# Skip: Not testing b/c requires network call
# function other_keymap_bif

# Skip: Not interesting to test
# function other_keymap_jcurl
