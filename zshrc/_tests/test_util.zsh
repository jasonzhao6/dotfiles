ls_dash_l=$(
	cat <<-eof
		drwxr-xr-x  9 yzhao  staff    288 Dec 29 21:58 al-archive
		-rw-r--r--  1 yzhao  staff    228 Dec 30 00:12 colordiffrc.txt
		-rw-r--r--@ 1 yzhao  staff    135 Dec 30 00:12 gitignore.txt
		-rw-r--r--@ 1 yzhao  staff     44 Dec 30 00:12 terraformrc.txt
		-rw-r--r--@ 1 yzhao  staff    871 Dec 30 00:12 tm_properties.txt
		drwxr-xr-x  6 yzhao  staff    192 Dec 29 21:58 vimium
		drwxr-xr-x  7 yzhao  staff    224 Dec 30 00:14 _tests
		-rwxr-xr-x@ 1 yzhao  staff   2208 Dec 30 00:12 _tests.zsh
		-rw-r--r--@ 1 yzhao  staff  23929 Dec 30 00:12 zshrc.txt
	eof
)

function test__d {
	assert "$(
		ZSHRC_UNDER_TEST=1 d www.google.com
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run_with_filter test__d

function test__d__without_input {
	assert "$(ZSHRC_UNDER_TEST=1 d)" ''
}; run_with_filter test__d__without_input

function test__d__with_protocol {
	assert "$(
		ZSHRC_UNDER_TEST=1 d https://www.google.com
	)" "$(
		cat <<-eof
		     1	test output for
		     2	www.google.com
		eof
	)"
}; run_with_filter test__d__with_protocol

function test__d__with_protocol_and_path {
	assert "$(
		ZSHRC_UNDER_TEST=1 d https://www.google.com/path/to/page
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

function test__l__with_search_pattern_to_ignore {
	assert "$(
		rm -rf /tmp/test__l--with-search-pattern-to-ignore
		mkdir /tmp/test__l--with-search-pattern-to-ignore
		cd /tmp/test__l--with-search-pattern-to-ignore || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		l ./*log | bw
		rm -rf /tmp/test__l--with-search-pattern-to-ignore
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
}; run_with_filter test__l__with_search_pattern_to_ignore

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

function test__ll__with_search_pattern_to_ignore {
	assert "$(
		rm -rf /tmp/test__ll--with-search-pattern-to-ignore
		mkdir /tmp/test__ll--with-search-pattern-to-ignore
		cd /tmp/test__ll--with-search-pattern-to-ignore || return
		mkdir 1 2 3
		mkdir .1.hidden
		touch 1.log 2.log 3.txt
		touch .2.hidden .3.hidden
		ll ./*log | bw
		rm -rf /tmp/test__ll--with-search-pattern-to-ignore
	)" "$(
		cat <<-eof
		     1	.1.hidden
		     2	.2.hidden
		     3	.3.hidden
		eof
	)"
}; run_with_filter test__ll__with_search_pattern_to_ignore

function test__w {
	assert "$(
		w w
	)" "$(
		cat <<-eof
		     1	w () {
		     2		which "\$@" | ss
		     3	}
		eof
	)"
}; run_with_filter test__w

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

function test__echo_eval {
	assert "$(
		echo_eval echo 123 2>&1
	)" "$(
		cat <<-eof
			echo 123
			123
		eof
	)"
}; run_with_filter test__echo_eval

function test__ellipsize {
	assert "$(
		ellipsize "$(printf "%.0sX" {1..1000})" | bw | wc -c | awk '{print $1}'
	)" "$COLUMNS"
}; run_with_filter test__ellipsize

function test__has_internet {
	# Skip: Not interesting to test
	return
}

function test__index_of__first {
	assert "$(index_of '10 20 30 40' 10)" '1'
}; run_with_filter test__index_of__first

function test__index_of__third {
	assert "$(index_of '10 20 30 40' 30)" '7'
}; run_with_filter test__index_of__third

function test__index_of__last {
	assert "$(index_of '10 20 30 40' 40)" '10'
}; run_with_filter test__index_of__last

function test__index_of__out_of_bound {
	assert "$(index_of '10 20 30 40' 100)" '0'
}; run_with_filter test__index_of__out_of_bound

function test__index_of__with_color {
	assert "$(index_of "$(green_bg a b c)" m)" '0'
}; run_with_filter test__index_of__with_color

function test__next_ascii__of_lower_case {
	assert "$(next_ascii a)" 'b'
}; run_with_filter test__next_ascii__of_lower_case

function test__next_ascii__of_upper_case {
	assert "$(next_ascii A)" 'B'
}; run_with_filter test__next_ascii__of_upper_case

function test__next_ascii__of_number {
	assert "$(next_ascii 0)" '1'
}; run_with_filter test__next_ascii__of_number

function test__paste_when_empty {
	assert "$(echo '123 321' | pbcopy; paste_when_empty)" '123 321'
}; run_with_filter test__paste_when_empty

function test__paste_when_empty__with_one_arg {
	assert "$(paste_when_empty 111)" '111'
}; run_with_filter test__paste_when_empty__with_one_arg

function test__paste_when_empty__with_two_args {
	assert "$(paste_when_empty '111 222')" '111 222'
}; run_with_filter test__paste_when_empty__with_two_args

function test__prev_command {
	# Skip: Cannot test b/c `fc -l` throws 'no such event' error
	return
}

function test__bw {
	assert "$(echo "\e[30m\e[47m...\e[0m" | bw)" '...'
}; run_with_filter test__bw

function test__compact {
	local input; input=$(
		cat <<-eof
			[


			]
		eof
	)

	assert "$(
		echo "$input" | compact
	)" "$(
		cat <<-eof
			[
			]
		eof
	)"
}; run_with_filter test__compact

function test__extract_urls {
	local url='http://example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls

function test__extract_urls__with_subdomain {
	local url='http://my.example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_subdomain

function test__extract_urls__with_www {
	local url='http://www.example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_www

function test__extract_urls__with_http {
	local url='http://www.example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_http

function test__extract_urls__with_https {
	local url='https://www.example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_https

function test__extract_urls__with_path {
	local url='https://www.example.com/path'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_path

function test__extract_urls__with_query {
	local url='https://www.example.com/path?key=value'
	assert "$(echo "$url" | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_query

function test__extract_urls__with_fragment {
	local url='https://www.example.com/path?key=value#heading'
	assert "$(echo "$url" | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_fragment

function test__extract_urls__with_multiple_urls {
	assert "$(
		echo '2 urls https://www.example.com/path?key=value#heading, https://www.google.com' | extract_urls
	)" "$(
		cat <<-eof
			$(pgrep_color 'https://www.example.com/path?key=value#heading')
			$(pgrep_color 'https://www.google.com')
		eof
	)"
}; run_with_filter test__extract_urls__with_multiple_urls

function test__hex {
	assert "$(
		echo 123 | hex
	)" "$(
		cat <<-eof
			00000000  31 32 33 0a                                       |123.|
			00000004
		eof
	)"
}; run_with_filter test__hex

function test__strip {
	assert "$(echo '    111 222   ' | strip)" '111 222'
}; run_with_filter test__strip

function test__strip_left {
	assert "$(echo '    111 222   ' | strip_left)" '111 222   '
}; run_with_filter test__strip_left

function test__strip_right {
	assert "$(echo '    111 222   ' | strip_right)" '    111 222'
}; run_with_filter test__strip_right

function test__trim {
	assert "$(echo 1234567890 | trim)" '1234567890'
}; run_with_filter test__trim

function test__trim__with_one_arg {
	assert "$(echo 1234567890 | trim 3)" '4567890'
}; run_with_filter test__trim__with_one_arg

function test__trim__with_two_args {
	assert "$(echo 1234567890 | trim 3 2)" '45678'
}; run_with_filter test__trim__with_two_args

function test__insert_hash {
	assert "$(
		# shellcheck disable=SC2086
		echo $ls_dash_l | insert_hash
	)" "$(
		cat <<-eof
			drwxr-xr-x  # 9 yzhao  staff    288 Dec 29 21:58 al-archive
			-rw-r--r--  # 1 yzhao  staff    228 Dec 30 00:12 colordiffrc.txt
			-rw-r--r--@ # 1 yzhao  staff    135 Dec 30 00:12 gitignore.txt
			-rw-r--r--@ # 1 yzhao  staff     44 Dec 30 00:12 terraformrc.txt
			-rw-r--r--@ # 1 yzhao  staff    871 Dec 30 00:12 tm_properties.txt
			drwxr-xr-x  # 6 yzhao  staff    192 Dec 29 21:58 vimium
			drwxr-xr-x  # 7 yzhao  staff    224 Dec 30 00:14 _tests
			-rwxr-xr-x@ # 1 yzhao  staff   2208 Dec 30 00:12 _tests.zsh
			-rw-r--r--@ # 1 yzhao  staff  23929 Dec 30 00:12 zshrc.txt
		eof
)"
}; run_with_filter test__insert_hash

function test__size_of {
	assert "$(echo "$ls_dash_l" | size_of)" '64'
}; run_with_filter test__size_of

function test__size_of__third_column {
	assert "$(echo "$ls_dash_l" | size_of 2)" '1'
}; run_with_filter test__size_of__third_column

function test__size_of__variable_width_column {
	# shellcheck disable=SC2086
	assert "$(echo $ls_dash_l | size_of 5)" '5'
}; run_with_filter test__size_of__variable_width_column

function test__keys {
	local input; input=$(
		cat <<-eof
			{
			  "key1": "value1",
			  "key2": "value2",
			  "key3": "value3"
			}
		eof
	)

	assert "$(
		echo "$input" | keys
	)" "$(
		cat <<-eof
		     1	key1
		     2	key2
		     3	key3
		eof
	)"
}; run_with_filter test__keys

function test__trim_list {
	local input; input=$(
		cat <<-eof
			[
			  "row-1",
			  "row-2",
			  "row-3"
			]
		eof
	)

	assert "$(
		echo "$input" | trim_list
	)" "$(
		cat <<-eof
			row-1
			row-2
			row-3
		eof
	)"
}; run_with_filter test__trim_list
