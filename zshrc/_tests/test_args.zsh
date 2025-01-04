input=$(
	cat <<-eof
		terraform-application-region-shared-1
		terraform-application-region-shared-2
		terraform-application-region-shared-3
		terraform-application-region-program-A
		terraform-application-region-program-B
	eof
)

input_short=$(
	cat <<-eof
		terraform-application-region-shared-1
		terraform-application-region-shared-2
	eof
)

input_with_whitespace=$(
	cat <<-eof
		  terraform-application-region-shared-1
		terraform-application-region-shared-2
		  terraform-application-region-shared-3
		terraform-application-region-program-A
	eof
)

input_with_headers=$(
	cat <<-eof
		MANIFEST                                COMMENT
		terraform-application-region-shared-1   hello world
		terraform-application-region-shared-2   foo bar
		terraform-application-region-shared-3   sup
		terraform-application-region-program-A  how are you
		terraform-application-region-program-B  select via headers for this one
	eof
)

input_with_headers_top_heavy=$(
	cat <<-eof
		MANIFEST                                COMMENT
		terraform-application-region-shared-1   hello world
		terraform-application-region-shared-2
		terraform-application-region-shared-3
		terraform-application-region-program-A
		terraform-application-region-program-B
	eof
)

input_with_tabs=$(
	cat <<-eof
		10.0.0.1	# 2023-06-21T20:25:00+00:00	webhook-asg
		10.0.0.2	# 2023-06-21T20:25:00+00:00	webhook-asg
		10.0.0.3	# 2023-06-21T20:24:59+00:00	webhook-asg
	eof
)

input_with_comments=$input_with_tabs

function test__s {
	# Can test `<command> | s`, but not `<command>; s`. The latter requires an interactive shell.
	assert "$(
		echo "$input_with_headers" | s
	)" "$(
		cat <<-eof
		     1	MANIFEST                                # COMMENT
		     2	terraform-application-region-shared-1   # hello world
		     3	terraform-application-region-shared-2   # foo bar
		     4	terraform-application-region-shared-3   # sup
		     5	terraform-application-region-program-A  # how are you
		     6	terraform-application-region-program-B  # select via headers for this one
		eof
	)"
}; run_with_filter test__s

function test__ss {
	# Can test `<command> | ss`, but not `<command>; ss`. The latter requires an interactive shell.
	assert "$(
		echo "$input_with_headers" | ss
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
		eof
	)"
}; run_with_filter test__ss

function test__v {
	assert "$(
		echo "$input_with_headers" | pbcopy
		v
	)" "$(
		cat <<-eof
		     1	MANIFEST                                # COMMENT
		     2	terraform-application-region-shared-1   # hello world
		     3	terraform-application-region-shared-2   # foo bar
		     4	terraform-application-region-shared-3   # sup
		     5	terraform-application-region-program-A  # how are you
		     6	terraform-application-region-program-B  # select via headers for this one
		eof
	)"
}; run_with_filter test__v

function test__vv {
	assert "$(
		echo "$input_with_headers" | pbcopy
		vv
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
		eof
	)"
}; run_with_filter test__vv

function test__a {
	assert "$(
		echo "$input" | ss > /dev/null
		a
	)" "$(
		cat <<-eof
		     1	terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		     5	terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__a

function test__a__adds_color {
	assert "$(
		echo "$input" | ss > /dev/null
		a shared
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep_color shared)-1
		     2	terraform-application-region-$(grep_color shared)-2
		     3	terraform-application-region-$(grep_color shared)-3
		eof
	)"
}; run_with_filter test__a__adds_color

function test__a__replaces_color {
	assert "$(
		echo "$input" | ss > /dev/null
		a shared > /dev/null
		a region
	)" "$(
		cat <<-eof
		     1	terraform-application-$(grep_color region)-shared-1
		     2	terraform-application-$(grep_color region)-shared-2
		     3	terraform-application-$(grep_color region)-shared-3
		eof
	)"
}; run_with_filter test__a__replaces_color

function test__a__with_two_args_out_of_order {
	assert "$(
		echo "$input" | ss > /dev/null
		a 2 shared
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep_color shared)-$(grep_color 2)
		eof
	)"
}; run_with_filter test__a__with_two_args_out_of_order

function test__a__with_two_args_including_negation {
	assert "$(
		echo "$input" | ss > /dev/null
		a -2 shared
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep_color shared)-1
		     2	terraform-application-region-$(grep_color shared)-3
		eof
	)"
}; run_with_filter test__a__with_two_args_including_negation

function test__aa {
	assert "$(
		echo "$input_short" | ss > /dev/null
		eee 1 $(($(args_list_size) * 3)) aa echo 2>&1 | sort | uniq
	)" "$(
		cat <<-eof

			aa echo
			echo terraform-application-region-shared-1
			echo terraform-application-region-shared-2
			terraform-application-region-shared-1
			terraform-application-region-shared-2
		eof
	)"
}; run_with_filter test__aa

function test__arg {
	assert "$(
		echo "$input" | ss > /dev/null
		arg 3 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-shared-3
			terraform-application-region-shared-3
		eof
	)"
}; run_with_filter test__arg

function test__arg__with_whitespace {
	assert "$(
		echo "$input_with_whitespace" | ss > /dev/null
		arg 3 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-shared-3
			terraform-application-region-shared-3
		eof
	)"
}; run_with_filter test__arg__with_whitespace

function test__arg__with_substitution {
	assert "$(
		echo "$input" | ss > /dev/null
		arg 3 echo http://~~:8080 2>&1
	)" "$(
		cat <<-eof
			echo http://terraform-application-region-shared-3:8080
			http://terraform-application-region-shared-3:8080
		eof
	)"
}; run_with_filter test__arg__with_substitution

function test__arg__with_multiple_substitutions {
	assert "$(
		echo "$input" | ss > /dev/null
		arg 3 echo http://~~:80 and https://~~:443 2>&1
	)" "$(
		cat <<-eof
			echo http://terraform-application-region-shared-3:80 and https://terraform-application-region-shared-3:443
			http://terraform-application-region-shared-3:80 and https://terraform-application-region-shared-3:443
		eof
	)"
}; run_with_filter test__arg__with_multiple_substitutions

function test__arg__with_multiple_substitutions_in_quotes {
	assert "$(
		echo "$input" | ss > /dev/null
		arg 3 'echo http://~~:80 and https://~~:443' 2>&1
	)" "$(
		cat <<-eof
			echo http://terraform-application-region-shared-3:80 and https://terraform-application-region-shared-3:443
			http://terraform-application-region-shared-3:80 and https://terraform-application-region-shared-3:443
		eof
	)"
}; run_with_filter test__arg__with_multiple_substitutions_in_quotes

function test__1 {
	assert "$(
		echo "$input" | ss > /dev/null
		1 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-shared-1
			terraform-application-region-shared-1
		eof
	)"
}; run_with_filter test__1

function test__5 {
	assert "$(
		echo "$input" | ss > /dev/null
		5 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-program-B
			terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__5

function test__6 {
	assert "$(
		echo "$input" | ss > /dev/null
		6 echo 2>&1
	)" "echo "
}; run_with_filter test__6

function test__0 {
	assert "$(
		echo "$input" | ss > /dev/null
		0 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-program-B
			terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__0

function test__e {
	assert "$(
		echo "$input" | ss > /dev/null
		e 3 4 echo 2>&1
	)" "$(
		cat <<-eof

			echo terraform-application-region-shared-3
			terraform-application-region-shared-3

			echo terraform-application-region-program-A
			terraform-application-region-program-A
		eof
	)"
}; run_with_filter test__e

function test__e__with_multiple_substitutions {
	assert "$(
		echo "$input" | ss > /dev/null
		e 3 4 echo ~~ and ~~ again 2>&1
	)" "$(
		cat <<-eof

			echo terraform-application-region-shared-3 and terraform-application-region-shared-3 again
			terraform-application-region-shared-3 and terraform-application-region-shared-3 again

			echo terraform-application-region-program-A and terraform-application-region-program-A again
			terraform-application-region-program-A and terraform-application-region-program-A again
		eof
	)"
}; run_with_filter test__e__with_multiple_substitutions

function test__each {
	assert "$(
		echo "$input" | ss > /dev/null
		each echo 2>&1
	)" "$(
		cat <<-eof

			echo terraform-application-region-shared-1
			terraform-application-region-shared-1

			echo terraform-application-region-shared-2
			terraform-application-region-shared-2

			echo terraform-application-region-shared-3
			terraform-application-region-shared-3

			echo terraform-application-region-program-A
			terraform-application-region-program-A

			echo terraform-application-region-program-B
			terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__each

function test__each__with_comments {
	assert "$(
		echo "$input_with_comments" | ss > /dev/null
		each echo 2>&1
	)" "$(
		cat <<-eof

			echo 10.0.0.1
			10.0.0.1

			echo 10.0.0.2
			10.0.0.2

			echo 10.0.0.3
			10.0.0.3
		eof
	)"
}; run_with_filter test__each__with_comments

function test__all {
	function test__all__sleep_and_echo { sleep "$@"; echo "$@"; }

	assert "$(
		printf '0.01\n0.03\n0.05' | ss > /dev/null
		all test__all__sleep_and_echo 2>/dev/null
	)" "$(
		cat <<-eof



			0.01
			0.03
			0.05
		eof
	)"
}; run_with_filter test__all

function test__map {
	assert "$(
		echo "$input" | ss > /dev/null
		map 'echo -n pre-; echo' 2>&1
	)" "$(
		cat <<-eof

			echo -n pre-; echo terraform-application-region-shared-1
			pre-terraform-application-region-shared-1

			echo -n pre-; echo terraform-application-region-shared-2
			pre-terraform-application-region-shared-2

			echo -n pre-; echo terraform-application-region-shared-3
			pre-terraform-application-region-shared-3

			echo -n pre-; echo terraform-application-region-program-A
			pre-terraform-application-region-program-A

			echo -n pre-; echo terraform-application-region-program-B
			pre-terraform-application-region-program-B

		     1	pre-terraform-application-region-shared-1
		     2	pre-terraform-application-region-shared-2
		     3	pre-terraform-application-region-shared-3
		     4	pre-terraform-application-region-program-A
		     5	pre-terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__map

function test__map__with_math {
	# shellcheck disable=SC2016
	assert "$(
		seq 1 5 | ss > /dev/null
		map echo ~~ doubles to '$((~~ * 10))' 2>&1
	)" "$(
		cat <<-eof

			echo 1 doubles to \$((1 * 10))
			1 doubles to 10

			echo 2 doubles to \$((2 * 10))
			2 doubles to 20

			echo 3 doubles to \$((3 * 10))
			3 doubles to 30

			echo 4 doubles to \$((4 * 10))
			4 doubles to 40

			echo 5 doubles to \$((5 * 10))
			5 doubles to 50

			     1	1 doubles to 10
			     2	2 doubles to 20
			     3	3 doubles to 30
			     4	4 doubles to 40
			     5	5 doubles to 50
		eof
	)"
}; run_with_filter test__map__with_math

function test__n {
	assert "$(
		echo "$input_with_tabs" | ss > /dev/null
		n
	)" "$(
		cat <<-eof
		     1	10.0.0.1	# 2023-06-21T20:25:00+00:00	webhook-asg
		     2	10.0.0.2	# 2023-06-21T20:25:00+00:00	webhook-asg
		     3	10.0.0.3	# 2023-06-21T20:24:59+00:00	webhook-asg
			$(green_bg '        a               b c                             d          ')
		eof
	)"
}; run_with_filter test__n

function test__n__when_selecting_first {
	assert "$(
		echo "$input_with_tabs" | ss > /dev/null
		n a
	)" "$(
		cat <<-eof
		     1	10.0.0.1
		     2	10.0.0.2
		     3	10.0.0.3
		eof
	)"
}; run_with_filter test__n__when_selecting_first

function test__n__when_selecting_third {
	assert "$(
		echo "$input_with_tabs" | ss > /dev/null
		n c
	)" "$(
		cat <<-eof
		     1	2023-06-21T20:25:00+00:00
		     2	2023-06-21T20:25:00+00:00
		     3	2023-06-21T20:24:59+00:00
		eof
	)"
}; run_with_filter test__n__when_selecting_third

function test__n__when_selecting_last {
	assert "$(
		echo "$input_with_tabs" | ss > /dev/null
		n d
	)" "$(
		cat <<-eof
		     1	webhook-asg
		     2	webhook-asg
		     3	webhook-asg
		eof
	)"
}; run_with_filter test__n__when_selecting_last

function test__n__when_selecting_with_color {
	assert "$(
		echo "$input_with_tabs" | grep 00 | ss > /dev/null
		n d
	)" "$(
		cat <<-eof
		     1	webhook-asg
		     2	webhook-asg
		     3	webhook-asg
		eof
	)"
}; run_with_filter test__n__when_selecting_with_color

function test__n__when_selecting_out_of_bound {
	assert "$(
		echo "$input_with_tabs" | ss > /dev/null
		n z
	)" "$(
		cat <<-eof
		     1	10.0.0.1        # 2023-06-21T20:25:00+00:00     webhook-asg
		     2	10.0.0.2        # 2023-06-21T20:25:00+00:00     webhook-asg
		     3	10.0.0.3        # 2023-06-21T20:24:59+00:00     webhook-asg
			$(green_bg '        a               b c                             d          ')
		eof
	)"
}; run_with_filter test__n__when_selecting_out_of_bound

function test__n__with_kubectl_get_pods_output {
	local input; input=$(
		cat <<-eof
			pod-1           1/1     Running     1 (15h ago)        15h
			pod-2           1/1     Running     0                  7d14h
			pod-3           1/1     Running     312 (8d ago)       43d
			pod-4           1/1     Running     0                  14h
		eof
	)

	assert "$(
		echo "$input" | ss > /dev/null
		n e
	)" "$(
		cat <<-eof
		     1	15h
		     2	7d14h
		     3	43d
		     4	14h
		eof
	)"
}; run_with_filter test__n__with_kubectl_get_pods_output

function test__n__with_one_column {
	assert "$(
		echo "$input" | ss > /dev/null
		n a
	)" "$(
		cat <<-eof
		     1	terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		     5	terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__n__with_one_column

function test__n__with_whitespace {
	assert "$(
		echo "$input_with_whitespace" | ss > /dev/null
		n a
	)" "$(
		cat <<-eof
		     1	  terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	  terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		eof
	)"
}; run_with_filter test__n__with_whitespace

function test__n__with_headers {
	assert "$(
		echo "$input_with_headers" | ss > /dev/null
		n
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
			$(green_bg '        a                                       b      c   d       e   f    g  ')
		eof
	)"
}; run_with_filter test__n__with_headers

function test__nn {
	assert "$(
		echo "$input_with_headers" | ss > /dev/null
		nn
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
			$(green_bg '        a                                       b      ')
		eof
	)"
}; run_with_filter test__nn

function test__nn__with_one_column {
	assert "$(
		echo "$input" | ss > /dev/null
		nn a
	)" "$(
		cat <<-eof
		     1	terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		     5	terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__nn__with_one_column

function test__c {
	assert "$(
		echo "$input" | ss > /dev/null
		c
		pbpaste
	)" "$(
		cat <<-eof
			terraform-application-region-shared-1
			terraform-application-region-shared-2
			terraform-application-region-shared-3
			terraform-application-region-program-A
			terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__c

function test__c__with_one_arg {
	assert "$(c '123'; pbpaste)" '123'
}; run_with_filter test__c__with_one_arg

function test__c__with_two_args {
	assert "$(c '123 321'; pbpaste)" '123 321'
}; run_with_filter test__c__with_two_args

function test__y {
	assert "$(
		echo "$input" | ss > /dev/null
		rm -f ~/.zshrc.args
		y
		cat ~/.zshrc.args
	)" "$input"
}; run_with_filter test__y

function test__p {
	assert "$(
		seq 3 > ~/.zshrc.args
		p
	)" "$(
		cat <<-eof
		     1	1
		     2	2
		     3	3
		eof
	)"
}; run_with_filter test__p

function test__u {
	assert "$(
		echo "$input" | ss > /dev/null
		a program > /dev/null
		u
	)" "$(
		cat <<-eof
		     1	terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		     5	terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__u

function test__u__when_undoing_n_with_headers {
	assert "$(
		echo "$input_with_headers" | ss > /dev/null
		n a > /dev/null
		u
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
			$(green_bg '        a                                       b      c   d       e   f    g  ')
		eof
	)"
}; run_with_filter test__u__when_undoing_n_with_headers

function test__u__when_undoing_nn_with_headers {
	assert "$(
		echo "$input_with_headers" | ss > /dev/null
		nn a > /dev/null
		u
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
			$(green_bg '        a                                       b      ')
		eof
	)"
}; run_with_filter test__u__when_undoing_nn_with_headers

function test__u__when_undoing_nn_then_requesting_n {
	assert "$(
		echo "$input_with_headers" | ss > /dev/null
		nn a > /dev/null
		u > /dev/null
		n
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
			$(green_bg '        a                                       b      c   d       e   f    g  ')
		eof
	)"
}; run_with_filter test__u__when_undoing_nn_then_requesting_n

function test__u__when_undoing_nn_with_headers_top_heavy {
	assert "$(
		echo "$input_with_headers_top_heavy" | ss > /dev/null
		nn a > /dev/null
		u
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2
		     4	terraform-application-region-shared-3
		     5	terraform-application-region-program-A
		     6	terraform-application-region-program-B
			$(green_bg '        a                                       b      ')
		eof
	)"
}; run_with_filter test__u__when_undoing_nn_with_headers_top_heavy

function test__u__when_undoing_ss_that_could_look_like_nn {
	assert "$(
		echo "$input_with_headers" | ss > /dev/null
		nn > /dev/null
		echo "$input_with_headers_top_heavy" | ss > /dev/null
		u
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
		eof
	)"
}; run_with_filter test__u__when_undoing_ss_that_could_look_like_nn

function test__u__when_undoing_x2 {
	assert "$(
		seq 1 2 | ss > /dev/null
		seq 2 3 | ss > /dev/null
		seq 3 4 | ss > /dev/null
		u > /dev/null
		u
	)" "$(
		cat <<-eof
		     1	1
		     2	2
		eof
	)"
}; run_with_filter test__u__when_undoing_x2

function test__u__when_undoing_beyond_tail {
	assert "$(
		seq 1 2 | ss > /dev/null
		seq 2 3 | ss > /dev/null
		seq 3 4 | ss > /dev/null
		u > /dev/null
		u > /dev/null
		u
	)" "$(
		cat <<-eof
		     1	1
		     2	2
		$(red_bg '  Reached the end of undo history  ')
		eof
	)"
}; run_with_filter test__u__when_undoing_beyond_tail

# shellcheck disable=SC2034
function test__u__when_pushing_beyond_head_then_undoing_beyond_tail {
	args_init
	ARGS_HISTORY_MAX=3

	assert "$(
		seq 1 2 | ss > /dev/null
		seq 2 3 | ss > /dev/null
		seq 3 4 | ss > /dev/null
		seq 4 5 | ss > /dev/null
		u > /dev/null
		u > /dev/null
		u
	)" "$(
		cat <<-eof
		     1	2
		     2	3
		$(red_bg '  Reached the end of undo history  ')
		eof
	)"

	args_reset
}; run_with_filter test__u__when_pushing_beyond_head_then_undoing_beyond_tail

function test__u__when_undoing_then_redoing_with_color {
	assert "$(
		echo "$input" | ss > /dev/null
		a program > /dev/null
		u > /dev/null
		r
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep_color program)-A
		     2	terraform-application-region-$(grep_color program)-B
		eof
	)"
}; run_with_filter test__u__when_undoing_then_redoing_with_color

function test__u__when_undoing_then_redoing_then_undoing_again_with_color {
	assert "$(
		echo "$input" | ss > /dev/null
		a program > /dev/null
		u > /dev/null
		a terraform > /dev/null
		a application > /dev/null
		r > /dev/null
		u
	)" "$(
		cat <<-eof
		     1	terraform-$(grep_color application)-region-shared-1
		     2	terraform-$(grep_color application)-region-shared-2
		     3	terraform-$(grep_color application)-region-shared-3
		     4	terraform-$(grep_color application)-region-program-A
		     5	terraform-$(grep_color application)-region-program-B
		eof
	)"
}; run_with_filter test__u__when_undoing_then_redoing_then_undoing_again_with_color

function test__r__when_redoing_x2 {
	assert "$(
		seq 1 2 | ss > /dev/null
		seq 2 3 | ss > /dev/null
		seq 3 4 | ss > /dev/null
		u > /dev/null
		u > /dev/null
		r > /dev/null
		r
	)" "$(
		cat <<-eof
		     1	3
		     2	4
		eof
	)"
}; run_with_filter test__r__when_redoing_x2

function test__r__when_redoing_beyond_head {
	assert "$(
		seq 1 2 | ss > /dev/null
		seq 2 3 | ss > /dev/null
		seq 3 4 | ss > /dev/null
		u > /dev/null
		u > /dev/null
		r > /dev/null
		r > /dev/null
		r
	)" "$(
		cat <<-eof
		     1	3
		     2	4
		$(red_bg '  Reached the end of redo history  ')
		eof
	)"
}; run_with_filter test__r__when_redoing_beyond_head

function test__r__when_redoing_beyond_new_head {
	assert "$(
		seq 1 2 | ss > /dev/null
		seq 2 3 | ss > /dev/null
		seq 3 4 | ss > /dev/null
		u > /dev/null
		u > /dev/null
		seq 4 5 | ss > /dev/null
		r
	)" "$(
		cat <<-eof
		     1	4
		     2	5
		$(red_bg '  Reached the end of redo history  ')
		eof
	)"
}; run_with_filter test__r__when_redoing_beyond_new_head

function test__i {
	assert "$(
		seq 1 2 | ss > /dev/null
		seq 2 3 | ss > /dev/null
		seq 3 4 | ss > /dev/null
		i
	)" "$(
		cat <<-eof
			cursor: 3
			head: 3
			tail: 1
			max: 100

			----------------------------------------
			Index 3
			----------------------------------------
			3
			4

			----------------------------------------
			Index 2
			----------------------------------------
			2
			3

			----------------------------------------
			Index 1
			----------------------------------------
			1
			2
		eof
	)"
}; run_with_filter test__i

function test__i__when_selecting_out_of_head_and_tail {
	assert "$(
		seq 1 2 | ss > /dev/null
		seq 2 3 | ss > /dev/null
		seq 3 4 | ss > /dev/null
		i 4
	)" "$(
		cat <<-eof
			cursor: 3
			head: 3
			tail: 1
			max: 100

			----------------------------------------
			Index 3
			----------------------------------------
			3
			4

			----------------------------------------
			Index 2
			----------------------------------------
			2
			3

			----------------------------------------
			Index 1
			----------------------------------------
			1
			2
		eof
	)"
}; run_with_filter test__i__when_selecting_out_of_head_and_tail

function test__i__when_selecting_head_index {
	assert "$(
		seq 1 2 | ss > /dev/null
		seq 2 3 | ss > /dev/null
		seq 3 4 | ss > /dev/null
		i 3
	)" "$(
		cat <<-eof
		     1	3
		     2	4
		eof
	)"
}; run_with_filter test__i__when_selecting_head_index

function test__i__when_selecting_middle_index {
	assert "$(
		seq 1 2 | ss > /dev/null
		seq 2 3 | ss > /dev/null
		seq 3 4 | ss > /dev/null
		i 2
	)" "$(
		cat <<-eof
		     1	2
		     2	3
		eof
	)"
}; run_with_filter test__i__when_selecting_middle_index

function test__i__when_selecting_tail_index {
	assert "$(
		seq 1 2 | ss > /dev/null
		seq 2 3 | ss > /dev/null
		seq 3 4 | ss > /dev/null
		i 1
	)" "$(
		cat <<-eof
		     1	1
		     2	2
		eof
	)"
}; run_with_filter test__i__when_selecting_tail_index

function test__args_save {
	assert "$(echo "$input" | args_save)" "$(
		cat <<-eof
		     1	terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		     5	terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__args_save

function test__args_save__with_leading_whitespace {
	assert "$(echo "$input_with_whitespace" | args_save)" "$(
		cat <<-eof
		     1	  terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	  terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		eof
	)"
}; run_with_filter test__args_save__with_leading_whitespace

function test__args_save__with_hash_inserted {
	# shellcheck disable=SC2016
	assert "$(echo "$input_with_headers" | args_save 'insert `#`')" "$(
		cat <<-eof
		     1	MANIFEST                                # COMMENT
		     2	terraform-application-region-shared-1   # hello world
		     3	terraform-application-region-shared-2   # foo bar
		     4	terraform-application-region-shared-3   # sup
		     5	terraform-application-region-program-A  # how are you
		     6	terraform-application-region-program-B  # select via headers for this one
		eof
	)"
}; run_with_filter test__args_save__with_hash_inserted
