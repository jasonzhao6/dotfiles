function test__d {
	assert "$(
		ZSHRC_UNDER_TESTING=1 d www.google.com
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run_with_filter test__d

function test__d__without_input {
	assert "$(ZSHRC_UNDER_TESTING=1 d)" ''
}; run_with_filter test__d__without_input

function test__d__with_protocol {
	assert "$(
		ZSHRC_UNDER_TESTING=1 d https://www.google.com
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run_with_filter test__d__with_protocol

function test__d__with_protocol_and_path {
	assert "$(
		ZSHRC_UNDER_TESTING=1 d https://www.google.com/path/to/page
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run_with_filter test__d__with_protocol_and_path

function test__f__for_gh {
	# Skip: Cannot test b/c requires querying github
	return
}

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

function test__l {
	assert "$(
		rm -rf /tmp/test__l
		mkdir /tmp/test__l
		cd /tmp/test__l || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		l | bw
		rm -rf /tmp/test__l
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
}; run_with_filter test__l

function test__l__with_filters {
	assert "$(
		rm -rf /tmp/test__l
		mkdir /tmp/test__l
		cd /tmp/test__l || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		l -1 log | bw
		rm -rf /tmp/test__l
	)" "$(
		cat <<-eof
		     1	2.log
		eof
	)"
}; run_with_filter test__l__with_filters

function test__ll {
	assert "$(
		rm -rf /tmp/test__ll
		mkdir /tmp/test__ll
		cd /tmp/test__ll || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		ll | bw
		rm -rf /tmp/test__ll
	)" "$(
		cat <<-eof
		     1	.1.hidden
		     2	.2.hidden
		     3	.3.hidden
		eof
	)"
}; run_with_filter test__ll

function test__ll__with_filters {
	assert "$(
		rm -rf /tmp/test__ll
		mkdir /tmp/test__ll
		cd /tmp/test__ll || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		ll -1 hidden | bw
		rm -rf /tmp/test__ll
	)" "$(
		cat <<-eof
		     1	.2.hidden
		     2	.3.hidden
		eof
	)"
}; run_with_filter test__ll__with_filters

function test__bb {
	# Skip: Not interesting to test
	return
}

function test__cc {
	# Skip: Cannot test b/c `fc -l` throws 'no such event' error
	return
}

function test__dd {
	# Skip: Not testing b/c requires network call
	return
}

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

function test__ee {
	assert "$(
		ee 3 4 echo ~~
	)" "$(
		cat <<-eof
			echo 3
			echo 4
		eof
	)"
}; run_with_filter test__ee

function test__ee__with_multiple_substitutions {
	assert "$(
		ee 3 4 echo ~~ and ~~ again
	)" "$(
		cat <<-eof
			echo 3 and 3 again
			echo 4 and 4 again
		eof
	)"
}; run_with_filter test__ee__with_multiple_substitutions

function test__ee__with_multiple_substitutions_in_quotes {
	assert "$(
		ee 3 4 'echo ~~ and ~~ again'
	)" "$(
		cat <<-eof
			echo 3 and 3 again
			echo 4 and 4 again
		eof
	)"
}; run_with_filter test__ee__with_multiple_substitutions_in_quotes

function test__ee__with_math {
	assert "$(
		ee 3 4 echo ~~ and '$((~~ + 10))' too
	)" "$(
		cat <<-eof
			echo 3 and \$((3 + 10)) too
			echo 4 and \$((4 + 10)) too
		eof
	)"
}; run_with_filter test__ee__with_math

function test__eee {
	assert "$(
		eee 3 4 echo ~~ 2>&1
	)" "$(
		cat <<-eof

			echo 3
			3

			echo 4
			4
		eof
	)"
}; run_with_filter test__eee

function test__eee__with_multiple_substitutions {
	assert "$(
		eee 3 4 echo ~~ and ~~ again 2>&1
	)" "$(
		cat <<-eof

			echo 3 and 3 again
			3 and 3 again

			echo 4 and 4 again
			4 and 4 again
		eof
	)"
}; run_with_filter test__eee__with_multiple_substitutions

function test__eee__with_multiple_substitutions_in_quotes {
	assert "$(
		eee 3 4 'echo ~~ and ~~ again' 2>&1
	)" "$(
		cat <<-eof

			echo 3 and 3 again
			3 and 3 again

			echo 4 and 4 again
			4 and 4 again
		eof
	)"
}; run_with_filter test__eee__with_multiple_substitutions_in_quotes

function test__eee__with_math {
	assert "$(
		eee 3 4 echo ~~ and '$((~~ + 10))' too 2>&1
	)" "$(
		cat <<-eof

			echo 3 and \$((3 + 10)) too
			3 and 13 too

			echo 4 and \$((4 + 10)) too
			4 and 14 too
		eof
	)"
}; run_with_filter test__eee__with_math

function test__ff {
	# Skip: Not interesting to test
	return
}

function test__hh {
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
		hh <(echo "$old") <(echo "$new") | bw
	)" "$(
		cat <<-eof
			This is the original content.                                   |       This is the modified content.
			                                                                >       New Line
		eof
	)"
}; run_with_filter test__hh

function test__ii {
	# Skip: Not interesting to test
	return
}

function test__mm {
	# Skip: Not interesting to test
	return
}

function test__oo {
	# Skip: Not interesting to test
	return
}

function test__pp {
	# Skip: Not interesting b/c it has its own specs
	return
}

function test__tt {
	# Skip: Not interesting to test
	return
}

function test__uu {
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
		uu <(echo "$old") <(echo "$new") | bw | sed 1,2d
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
}; run_with_filter test__uu

function test__xx {
	assert "$(
		xx
		pbpaste
	)" "$(
		cat <<-eof
			bind '"\e[A": history-search-backward'
			bind '"\e[B": history-search-forward'
		eof
	)"
}; run_with_filter test__xx

function test__bif {
	# Skip: Not testing b/c requires network call
	return
}

function test__flush {
	# Skip: Not testing b/c requires network call
	return
}

function test__jcurl {
	# Skip: Not interesting to test
	return
}

function test__ren {
	assert "$(
		rm -rf /tmp/test__ren
		mkdir /tmp/test__ren
		cd /tmp/test__ren || return
		touch 1.log 2.log 3.txt
		ren log txt
		ls
		rm -rf /tmp/test__ren
	)" "$(
		cat <<-eof
			1.txt
			2.txt
			3.txt
		eof
	)"
}; run_with_filter test__ren
