ls_dash_l=$(
	cat <<-eof
		drwxr-xr-x  9 yzhao  staff    288 Dec 29 21:58 al-archive
		-rw-r--r--  1 yzhao  staff    228 Dec 30 00:12 colordiffrc.txt
		-rw-r--r--@ 1 yzhao  staff    135 Dec 30 00:12 gitignore.txt
		-rw-r--r--@ 1 yzhao  staff     44 Dec 30 00:12 terraformrc.txt
		-rw-r--r--@ 1 yzhao  staff    871 Dec 30 00:12 tm_properties.txt
		drwxr-xr-x  6 yzhao  staff    192 Dec 29 21:58 vimium
		drwxr-xr-x  7 yzhao  staff    224 Dec 30 00:14 zshrc-tests
		-rwxr-xr-x@ 1 yzhao  staff   2208 Dec 30 00:12 zshrc-tests.zsh
		-rw-r--r--@ 1 yzhao  staff  23929 Dec 30 00:12 zshrc.txt
	eof
)

function test--d {
	assert "$(
		D_UNDER_TEST=1 d www.google.com
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run-with-filter test--d

function test--d--without-input {
	assert "$(D_UNDER_TEST=1 d)" ''
}; run-with-filter test--d--without-input

function test--d--with-protocol {
	assert "$(
		D_UNDER_TEST=1 d https://www.google.com
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run-with-filter test--d--with-protocol

function test--d--with-protocol-and-path {
	assert "$(
		D_UNDER_TEST=1 d https://www.google.com/path/to/page
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run-with-filter test--d--with-protocol-and-path

function test--f--for-gh {
	# Skip: Cannot test b/c requires querying github
}

function test--f--for-tf {
	assert "$(
		local home=$HOME
		local pwd=$PWD
		HOME="/tmp/test--f"
		mkdir -p $HOME/project/module/.terraform

		touch $HOME/project/main.tf
		touch $HOME/project/module/main.tf
		touch $HOME/project/module/.terraform/main.tf

		cd $HOME
		f tf

		rm -rf $HOME
		HOME=$home
		cd $pwd
	)" "$(
		cat <<-eof
		     1	~/project
		     2	~/project/module
		eof
	)"
}; run-with-filter test--f--for-tf

function test--i {
	assert "$(
		i i
	)" "$(
		cat <<-eof
		     1	i () {
		     2		which \$@ | save-args
		     3	}
		eof
	)"
}; run-with-filter test--i

function test--l {
	assert "$(
		rm -rf /tmp/test--l
		mkdir /tmp/test--l
		cd /tmp/test--l
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		l | no-color
		rm -rf /tmp/test--l
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
}; run-with-filter test--l

function test--l--with-search-pattern-to-ignore {
	assert "$(
		rm -rf /tmp/test--l--with-search-pattern-to-ignore
		mkdir /tmp/test--l--with-search-pattern-to-ignore
		cd /tmp/test--l--with-search-pattern-to-ignore
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		l *log | no-color
		rm -rf /tmp/test--l--with-search-pattern-to-ignore
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
}; run-with-filter test--l--with-search-pattern-to-ignore

function test--ll {
	assert "$(
		rm -rf /tmp/test--ll
		mkdir /tmp/test--ll
		cd /tmp/test--ll
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		ll | no-color
		rm -rf /tmp/test--ll
	)" "$(
		cat <<-eof
		     1	.1.hidden
		     2	.2.hidden
		     3	.3.hidden
		eof
	)"
}; run-with-filter test--ll

function test--ll--with-search-pattern-to-ignore {
	assert "$(
		rm -rf /tmp/test--ll--with-search-pattern-to-ignore
		mkdir /tmp/test--ll--with-search-pattern-to-ignore
		cd /tmp/test--ll--with-search-pattern-to-ignore
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		ll *log | no-color
		rm -rf /tmp/test--ll--with-search-pattern-to-ignore
	)" "$(
		cat <<-eof
		     1	.1.hidden
		     2	.2.hidden
		     3	.3.hidden
		eof
	)"
}; run-with-filter test--ll--with-search-pattern-to-ignore

function test--bb {
	# Skip: Not interesting to test
}

function test--cc {
	# Skip: Cannot test b/c `fc -l` throws 'no such event' error
}

function test--dd {
	# Skip: Not testing b/c requires network call
}

function test--dd {
	assert "$(
		DD_DUMP_DIR="/tmp/test--dd"
		DD_CLEAR_TERMINAL=0
		rm -rf $DD_DUMP_DIR

		echo '$' | pbcopy
		dd
		ls -l $DD_DUMP_DIR | wc -l | awk '{print $1 - 1}'
		cat $DD_DUMP_DIR/*

		dd-init
		rm -rf $DD_DUMP_DIR
	)" "$(
		cat <<-eof
			1
			$
		eof
	)"
}; run-with-filter test--dd

function test--dd--when-dumping-same-pasteboard-twice {
	assert "$(
		DD_DUMP_DIR="/tmp/test--dd"
		DD_CLEAR_TERMINAL=0
		rm -rf $DD_DUMP_DIR

		echo '$' | pbcopy
		dd
		dd
		ls -l $DD_DUMP_DIR | wc -l | awk '{print $1 - 1}'
		cat $DD_DUMP_DIR/*

		dd-init
		rm -rf $DD_DUMP_DIR
	)" "$(
		cat <<-eof
			1
			$
		eof
	)"
}; run-with-filter test--dd--when-dumping-same-pasteboard-twice

function test--dd--when-dumping-two-different-pasteboards {
	assert "$(
		DD_DUMP_DIR="/tmp/test--dd"
		DD_CLEAR_TERMINAL=0
		rm -rf $DD_DUMP_DIR

		echo "pasteboard 1\n$" | pbcopy
		dd
		echo "pasteboard 2\n$" | pbcopy
		dd
		ls -l $DD_DUMP_DIR | wc -l | awk '{print $1 - 1}'
		cat $DD_DUMP_DIR/*

		dd-init
		rm -rf $DD_DUMP_DIR
	)" "$(
		cat <<-eof
			2
			pasteboard 1
			$
			pasteboard 2
			$
		eof
	)"
}; run-with-filter test--dd--when-dumping-two-different-pasteboards

function test--dd--when-not-terminal-output {
	assert "$(
		DD_DUMP_DIR="/tmp/test--dd"
		DD_CLEAR_TERMINAL=0
		rm -rf $DD_DUMP_DIR

		echo 'not terminal output' | pbcopy
		dd
		ls -l $DD_DUMP_DIR | wc -l | awk '{print $1 - 1}'

		dd-init
	)" '0'
}; run-with-filter test--dd--when-not-terminal-output

function test--ddd {
	assert "$(ddd; pwd)" "$DD_DUMP_DIR"
}; run-with-filter test--ddd

function test--ddc {
	assert "$(
		DD_DUMP_DIR="/tmp/test--dd"
		mkdir -p $DD_DUMP_DIR

		ddc
		[[ -e $DD_DUMP_DIR ]] && echo present || echo absent

		dd-init
	)" 'absent'
}; run-with-filter test--ddc

function test--ee {
	assert "$(
		ee 3 4 echo ~~
	)" "$(
		cat <<-eof
			echo 3
			echo 4
		eof
	)"
}; run-with-filter test--ee

function test--ee--with-multiple-substitutions {
	assert "$(
		ee 3 4 echo ~~ and ~~ again
	)" "$(
		cat <<-eof
			echo 3 and 3 again
			echo 4 and 4 again
		eof
	)"
}; run-with-filter test--ee--with-multiple-substitutions

function test--ee--with-multiple-substitutions-in-quotes {
	assert "$(
		ee 3 4 'echo ~~ and ~~ again'
	)" "$(
		cat <<-eof
			echo 3 and 3 again
			echo 4 and 4 again
		eof
	)"
}; run-with-filter test--ee--with-multiple-substitutions-in-quotes

function test--ee--with-math {
	assert "$(
		ee 3 4 echo ~~ and '$((~~ + 10))' too
	)" "$(
		cat <<-eof
			echo 3 and \$((3 + 10)) too
			echo 4 and \$((4 + 10)) too
		eof
	)"
}; run-with-filter test--ee--with-math

function test--eee {
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
}; run-with-filter test--eee

function test--eee--with-multiple-substitutions {
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
}; run-with-filter test--eee--with-multiple-substitutions

function test--eee--with-multiple-substitutions-in-quotes {
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
}; run-with-filter test--eee--with-multiple-substitutions-in-quotes

function test--eee--with-math {
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
}; run-with-filter test--eee--with-math

function test--ff {
	# Skip: Not interesting to test
}

function test--hh {
	local old=$(
		cat <<-eof
			This is the original content.
			Line 1
			Line 2
			Line 3
			Line 4
		eof
	)

	local new=$(
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
		hh <(echo $old) <(echo $new) | no-color
	)" "$(
		cat <<-eof
			This is the original content.                                   |       This is the modified content.
			                                                                >       New Line
		eof
	)"
}; run-with-filter test--hh

function test--ii {
	# Skip: Not interesting to test
}

function test--mm {
	# Skip: Not interesting to test
}

function test--oo {
	# Skip: Not interesting to test
}

function test--pp {
	# Skip: Not interesting b/c it has its own specs
}

function test--tt {
	# Skip: Not interesting to test
}

function test--uu {
	local old=$(
		cat <<-eof
			This is the original content.
			Line 1
			Line 2
			Line 3
			Line 4
		eof
	)

	local new=$(
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
		uu <(echo $old) <(echo $new) | no-color | sed 1,2d
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
}; run-with-filter test--uu

function test--xx {
	assert "$(
		xx
		pbpaste
	)" "$(
		cat <<-eof
			bind '"\e[A": history-search-backward'
			bind '"\e[B": history-search-forward'
		eof
	)"
}; run-with-filter test--xx

function test--bif {
	# Skip: Not testing b/c requires network call
}

function test--flush {
	# Skip: Not testing b/c requires network call
}

function test--jcurl {
	# Skip: Not interesting to test
}

function test--ren {
	assert "$(
		rm -rf /tmp/test--ren
		mkdir /tmp/test--ren
		cd /tmp/test--ren
		touch 1.log 2.log 3.txt
		ren log txt
		ls
		rm -rf /tmp/test--ren
	)" "$(
		cat <<-eof
			1.txt
			2.txt
			3.txt
		eof
	)"
}; run-with-filter test--ren

function test--echo-eval {
	assert "$(
		echo-eval echo 123 2>&1
	)" "$(
		cat <<-eof
			echo 123
			123
		eof
	)"
}; run-with-filter test--echo-eval

function test--ellipsize {
	assert "$(
		ellipsize $(printf "%.0sX" {1..1000}) | no-color | wc -c | awk '{print $1}'
	)" "$COLUMNS"
}; run-with-filter test--ellipsize

function test--has-internet {
	# Skip: Not interesting to test
}

function test--index-of--first {
	assert "$(index-of '10 20 30 40' 10)" '1'
}; run-with-filter test--index-of--first

function test--index-of--third {
	assert "$(index-of '10 20 30 40' 30)" '7'
}; run-with-filter test--index-of--third

function test--index-of--last {
	assert "$(index-of '10 20 30 40' 40)" '10'
}; run-with-filter test--index-of--last

function test--index-of--out-of-bound {
	assert "$(index-of '10 20 30 40' 100)" '0'
}; run-with-filter test--index-of--out-of-bound

function test--index-of--with-color {
	assert "$(index-of "$(green-bg a b c)" m)" '0'
}; run-with-filter test--index-of--with-color

function test--next-ascii--of-lower-case {
	assert "$(next-ascii a)" 'b'
}; run-with-filter test--next-ascii--of-lower-case

function test--next-ascii--of-upper-case {
	assert "$(next-ascii A)" 'B'
}; run-with-filter test--next-ascii--of-upper-case

function test--next-ascii--of-number {
	assert "$(next-ascii 0)" '1'
}; run-with-filter test--next-ascii--of-number

function test--paste-when-empty {
	assert "$(echo '123 321' | pbcopy; paste-when-empty)" '123 321'
}; run-with-filter test--paste-when-empty

function test--paste-when-empty--with-one-arg {
	assert "$(paste-when-empty 111)" '111'
}; run-with-filter test--paste-when-empty--with-one-arg

function test--paste-when-empty--with-two-args {
	assert "$(paste-when-empty '111 222')" '111 222'
}; run-with-filter test--paste-when-empty--with-two-args

function test--prev-command {
	# Skip: Cannot test b/c `fc -l` throws 'no such event' error
}

function test--hex {
	assert "$(
		echo 123 | hex
	)" "$(
		cat <<-eof
			00000000  31 32 33 0a                                       |123.|
			00000004
		eof
	)"
}; run-with-filter test--hex

function test--no-color {
	assert "$(echo "\e[30m\e[47m...\e[0m" | no-color)" '...'
}; run-with-filter test--no-color

function test--no-empty {
	local input=$(
		cat <<-eof
			[


			]
		eof
	)

	assert "$(
		echo $input | no-empty
	)" "$(
		cat <<-eof
			[
			]
		eof
	)"
}; run-with-filter test--no-empty

function test--strip {
	assert "$(echo '    111 222   ' | strip)" '111 222'
}; run-with-filter test--strip

function test--trim {
	assert "$(echo 1234567890 | trim)" '1234567890'
}; run-with-filter test--trim

function test--trim--with-one-arg {
	assert "$(echo 1234567890 | trim 3)" '4567890'
}; run-with-filter test--trim--with-one-arg

function test--trim--with-two-args {
	assert "$(echo 1234567890 | trim 3 2)" '45678'
}; run-with-filter test--trim--with-two-args

function test--insert-hash {
	assert "$(
		echo $ls_dash_l | insert-hash
	)" "$(
		cat <<-eof
			drwxr-xr-x  # 9 yzhao  staff    288 Dec 29 21:58 al-archive
			-rw-r--r--  # 1 yzhao  staff    228 Dec 30 00:12 colordiffrc.txt
			-rw-r--r--@ # 1 yzhao  staff    135 Dec 30 00:12 gitignore.txt
			-rw-r--r--@ # 1 yzhao  staff     44 Dec 30 00:12 terraformrc.txt
			-rw-r--r--@ # 1 yzhao  staff    871 Dec 30 00:12 tm_properties.txt
			drwxr-xr-x  # 6 yzhao  staff    192 Dec 29 21:58 vimium
			drwxr-xr-x  # 7 yzhao  staff    224 Dec 30 00:14 zshrc-tests
			-rwxr-xr-x@ # 1 yzhao  staff   2208 Dec 30 00:12 zshrc-tests.zsh
			-rw-r--r--@ # 1 yzhao  staff  23929 Dec 30 00:12 zshrc.txt
		eof
)"
}; run-with-filter test--insert-hash

function test--size-of {
	assert "$(echo $ls_dash_l | size-of)" '64'
}; run-with-filter test--size-of

function test--size-of--third-column {
	assert "$(echo $ls_dash_l | size-of 2)" '1'
}; run-with-filter test--size-of--third-column

function test--size-of--variable-width-column {
	assert "$(echo $ls_dash_l | size-of 5)" '5'
}; run-with-filter test--size-of--variable-width-column

function test--keys {
	local input=$(
		cat <<-eof
			{
			  "key1": "value1",
			  "key2": "value2",
			  "key3": "value3"
			}
		eof
	)

	assert "$(
		echo $input | keys
	)" "$(
		cat <<-eof
		     1	key1
		     2	key2
		     3	key3
		eof
	)"
}; run-with-filter test--keys

function test--trim-list {
	local input=$(
		cat <<-eof
			[
			  "row-1",
			  "row-2",
			  "row-3"
			]
		eof
	)

	assert "$(
		echo $input | trim-list
	)" "$(
		cat <<-eof
			row-1
			row-2
			row-3
		eof
	)"
}; run-with-filter test--trim-list
