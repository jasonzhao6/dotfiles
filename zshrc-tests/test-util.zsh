function test_hh {
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

	local output=$(hh <(echo $old) <(echo $new) | no-color )

	local expected=$(
		cat <<-eof
			This is the original content.                                   |       This is the modified content.
			                                                                >       New Line
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_hh'
}; test_hh

function test_uu {
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

	local output=$(uu <(echo $old) <(echo $new) | no-color | sed 1,2d )

	local expected=$(
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
	)

	[[ $output == $expected ]] && pass || fail 'test_uu'
}; test_uu

function test_bb {
	# Not interesting to test
}

function test_cc {
	# Cannot test b/c `fc -l` throws 'no such event' error
}

function test_dd {
	# Not testing b/c requires network call
}

function test_ee {
	local output=$(
		ee
		pbpaste
	)

	local expected=$(
		cat <<-eof
			bind '"\e[A": history-search-backward'
			bind '"\e[B": history-search-forward'
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_ee'
}; test_ee

function test_ff {
	# Not interesting to test
}

function test_ii {
	# Not interesting to test
}

function test_jj {
	# Not interesting to test
}

function test_ll {
	local output=$(ll 10 5 echo pre~~post)

	local expected=$(
		cat <<-eof
			echo pre10post
			echo pre9post
			echo pre8post
			echo pre7post
			echo pre6post
			echo pre5post
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_ll'
}; test_ll

function test_lll {
	local output=$(lll 10 5 echo pre~~post)

	local expected=$(
		cat <<-eof
			pre10post
			pre9post
			pre8post
			pre7post
			pre6post
			pre5post
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_lll'
}; test_lll

function test_mm {
	# Not interesting to test
}

function test_nn {
	local output=$(
		rm -rf /tmp/test_nn
		mkdir /tmp/test_nn
		cd /tmp/test_nn
		mkdir -p shared/1
		mkdir -p shared/2
		mkdir -p shared/3
		mkdir -p program_a
		mkdir -p program_b
		touch shared/1/main.tf
		touch shared/2/main.tf
		touch shared/3/main.tf
		touch program_a/main.tf
		touch program_b/main.tf
		nn
	)

	rm -rf /tmp/test_nn

	local expected=$(
		cat <<-eof
			     1	/tmp/test_nn/program_a
			     2	/tmp/test_nn/program_b
			     3	/tmp/test_nn/shared/1
			     4	/tmp/test_nn/shared/2
			     5	/tmp/test_nn/shared/3
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_nn'
}; test_nn

function test_oo {
	# Not interesting to test
}

function test_tt {
	# Not interesting to test
}

function test_bif {
	# Not testing b/c requires network call
}

function test_e {
	# Not interesting to test
}

function test_flush-dns {
	# Not testing b/c requires network call
}

function test_ren {
	local output=$(
		rm -rf /tmp/test_ren
		mkdir /tmp/test_ren
		cd /tmp/test_ren
		touch 1.log 2.log 3.txt
		ren log txt
		ls
	)

	rm -rf /tmp/test_ren

	local expected=$(
		cat <<-eof
			1.txt
			2.txt
			3.txt
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_ren'
}; test_ren

function test_echo-eval {
	local output=$(echo-eval echo 123 2>&1)
	local expected=$(
		cat <<-eof
			echo 123
			123
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_echo-eval'
}; test_echo-eval

function test_ellipsize {
	local output=$(ellipsize $(printf "%.0sX" {1..1000}) | no-color)

	[[ ${#output} -eq $COLUMNS ]] && pass || fail 'test_ellipsize'
}; test_ellipsize

function test_paste-fallback_0_arg {
	local input='123 321'
	local output=$(echo $input | pbcopy; paste-fallback)
	local expected=$input

	[[ $output == $expected ]] && pass || fail 'test_paste-fallback_0_arg'
}; test_paste-fallback_0_arg

function test_paste-fallback_1_arg {
	local input='111'
	local output=$(paste-fallback $input)
	local expected=$input

	[[ $output == $expected ]] && pass || fail 'test_paste-fallback_1_arg'
}; test_paste-fallback_1_arg

function test_paste-fallback_2_args {
	local input='111 222'
	local output=$(paste-fallback $input)
	local expected=$input

	[[ $output == $expected ]] && pass || fail 'test_paste-fallback_2_args'
}; test_paste-fallback_2_args

function test_naked-list {
	local input=$(
		cat <<-eof
			  "row-1",
			  "row-2",
			  "row-3"
		eof
	)

	local output=$(echo $input | naked-list)

	local expected=$(
		cat <<-eof
			row-1
			row-2
			row-3
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_naked-list'
}; test_naked-list

function test_no-color {
	local output=$(echo "\e[30m\e[47m...\e[0m" | no-color)

	[[ ${#output} -eq 3 ]] && pass || fail 'test_no-color'
}; test_no-color

function test_trim-when-0-arg {
	local input='1234567890'
	local output=$(echo $input | trim)
	local expected=$input

	[[ $output == $expected ]] && pass || fail 'test_trim-when-0-arg'
}; test_trim-when-0-arg

function test_trim-when-1-arg {
	local input='1234567890'
	local output=$(echo $input | trim 3)
	local expected='4567890'

	[[ $output == $expected ]] && pass || fail 'test_trim-when-1-arg'
}; test_trim-when-1-arg

function test_trim-when-2-args {
	local input='1234567890'
	local output=$(echo $input | trim 3 2)
	local expected='45678'

	[[ $output == $expected ]] && pass || fail 'test_trim-when-2-args'
}; test_trim-when-2-args
