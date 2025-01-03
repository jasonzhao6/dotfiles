input=$(
	cat <<-eof
		terraform-application-region-shared-1
		terraform-application-region-shared-2
		terraform-application-region-shared-3
		terraform-application-region-program-A
		terraform-application-region-program-B
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

function test--s {
	# Can test `<command> | s`, but not `<command>; s`. The latter requires an interactive shell.
	assert "$(
		echo $input_with_headers | s
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
}; run-with-filter test--s

function test--ss {
	# Can test `<command> | ss`, but not `<command>; ss`. The latter requires an interactive shell.
	assert "$(
		echo $input_with_headers | ss
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
}; run-with-filter test--ss

function test--v {
	assert "$(
		echo $input_with_headers | pbcopy
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
}; run-with-filter test--v

function test--vv {
	assert "$(
		echo $input_with_headers | pbcopy
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
}; run-with-filter test--vv

function test--a {
	assert "$(
		echo $input | ss > /dev/null
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
}; run-with-filter test--a

function test--a--adds-color {
	assert "$(
		echo $input | ss > /dev/null
		a shared
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep-color shared)-1
		     2	terraform-application-region-$(grep-color shared)-2
		     3	terraform-application-region-$(grep-color shared)-3
		eof
	)"
}; run-with-filter test--a--adds-color

function test--a--replaces-color {
	assert "$(
		echo $input | ss > /dev/null
		a shared > /dev/null
		a region
	)" "$(
		cat <<-eof
		     1	terraform-application-$(grep-color region)-shared-1
		     2	terraform-application-$(grep-color region)-shared-2
		     3	terraform-application-$(grep-color region)-shared-3
		eof
	)"
}; run-with-filter test--a--replaces-color

function test--a--with-two-args-out-of-order {
	assert "$(
		echo $input | ss > /dev/null
		a 2 shared
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep-color shared)-$(grep-color 2)
		eof
	)"
}; run-with-filter test--a--with-two-args-out-of-order

function test--a--with-two-args-including-negation {
	assert "$(
		echo $input | ss > /dev/null
		a -2 shared
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep-color shared)-1
		     2	terraform-application-region-$(grep-color shared)-3
		eof
	)"
}; run-with-filter test--a--with-two-args-including-negation

function test--aa {
	assert "$(
		echo $input | ss > /dev/null
		eee 1 $(($(args-list-size) * 10)) aa echo 2>&1 | sort | uniq
	)" "$(
		cat <<-eof

			aa echo
			echo terraform-application-region-program-A
			echo terraform-application-region-program-B
			echo terraform-application-region-shared-1
			echo terraform-application-region-shared-2
			echo terraform-application-region-shared-3
			terraform-application-region-program-A
			terraform-application-region-program-B
			terraform-application-region-shared-1
			terraform-application-region-shared-2
			terraform-application-region-shared-3
		eof
	)"
}; run-with-filter test--aa

function test--arg {
	assert "$(
		echo $input | ss > /dev/null
		arg 3 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-shared-3
			terraform-application-region-shared-3
		eof
	)"
}; run-with-filter test--arg

function test--arg--with-whitespace {
	assert "$(
		echo $input_with_whitespace | ss > /dev/null
		arg 3 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-shared-3
			terraform-application-region-shared-3
		eof
	)"
}; run-with-filter test--arg--with-whitespace

function test--arg--with-substitution {
	assert "$(
		echo $input | ss > /dev/null
		arg 3 echo http://~~:8080 2>&1
	)" "$(
		cat <<-eof
			echo http://terraform-application-region-shared-3:8080
			http://terraform-application-region-shared-3:8080
		eof
	)"
}; run-with-filter test--arg--with-substitution

function test--arg--with-multiple-substitutions {
	assert "$(
		echo $input | ss > /dev/null
		arg 3 echo http://~~:80 and https://~~:443 2>&1
	)" "$(
		cat <<-eof
			echo http://terraform-application-region-shared-3:80 and https://terraform-application-region-shared-3:443
			http://terraform-application-region-shared-3:80 and https://terraform-application-region-shared-3:443
		eof
	)"
}; run-with-filter test--arg--with-multiple-substitutions

function test--arg--with-multiple-substitutions-in-quotes {
	assert "$(
		echo $input | ss > /dev/null
		arg 3 'echo http://~~:80 and https://~~:443' 2>&1
	)" "$(
		cat <<-eof
			echo http://terraform-application-region-shared-3:80 and https://terraform-application-region-shared-3:443
			http://terraform-application-region-shared-3:80 and https://terraform-application-region-shared-3:443
		eof
	)"
}; run-with-filter test--arg--with-multiple-substitutions-in-quotes

function test--1 {
	assert "$(
		echo $input | ss > /dev/null
		1 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-shared-1
			terraform-application-region-shared-1
		eof
	)"
}; run-with-filter test--1

function test--5 {
	assert "$(
		echo $input | ss > /dev/null
		5 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-program-B
			terraform-application-region-program-B
		eof
	)"
}; run-with-filter test--5

function test--6 {
	assert "$(
		echo $input | ss > /dev/null
		6 echo 2>&1
	)" "echo "
}; run-with-filter test--6

function test--0 {
	assert "$(
		echo $input | ss > /dev/null
		0 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-program-B
			terraform-application-region-program-B
		eof
	)"
}; run-with-filter test--0

function test--e {
	assert "$(
		echo $input | ss > /dev/null
		e 3 4 echo 2>&1
	)" "$(
		cat <<-eof

			echo terraform-application-region-shared-3
			terraform-application-region-shared-3

			echo terraform-application-region-program-A
			terraform-application-region-program-A
		eof
	)"
}; run-with-filter test--e

function test--e--with-multiple-substitutions {
	assert "$(
		echo $input | ss > /dev/null
		e 3 4 echo ~~ and ~~ again 2>&1
	)" "$(
		cat <<-eof

			echo terraform-application-region-shared-3 and terraform-application-region-shared-3 again
			terraform-application-region-shared-3 and terraform-application-region-shared-3 again

			echo terraform-application-region-program-A and terraform-application-region-program-A again
			terraform-application-region-program-A and terraform-application-region-program-A again
		eof
	)"
}; run-with-filter test--e--with-multiple-substitutions

function test--each {
	assert "$(
		echo $input | ss > /dev/null
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
}; run-with-filter test--each

function test--each--with-comments {
	assert "$(
		echo $input_with_comments | ss > /dev/null
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
}; run-with-filter test--each--with-comments

function test--all {
	function test--all--sleep-and-echo { sleep $@; echo $@ }

	assert "$(
		echo '0.01\n0.03\n0.05' | ss > /dev/null
		all test--all--sleep-and-echo 2>/dev/null
	)" "$(
		cat <<-eof



			0.01
			0.03
			0.05
		eof
	)"
}; run-with-filter test--all

function test--map {
	assert "$(
		echo $input | ss > /dev/null
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
}; run-with-filter test--map

function test--map--with-math {
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
}; run-with-filter test--map--with-math

function test--n {
	assert "$(
		echo $input_with_tabs | ss > /dev/null
		n
	)" "$(
		cat <<-eof
		     1	10.0.0.1	# 2023-06-21T20:25:00+00:00	webhook-asg
		     2	10.0.0.2	# 2023-06-21T20:25:00+00:00	webhook-asg
		     3	10.0.0.3	# 2023-06-21T20:24:59+00:00	webhook-asg
			$(green-bg '        a               b c                             d          ')
		eof
	)"
}; run-with-filter test--n

function test--n--when-selecting-first {
	assert "$(
		echo $input_with_tabs | ss > /dev/null
		n a
	)" "$(
		cat <<-eof
		     1	10.0.0.1
		     2	10.0.0.2
		     3	10.0.0.3
		eof
	)"
}; run-with-filter test--n--when-selecting-first

function test--n--when-selecting-third {
	assert "$(
		echo $input_with_tabs | ss > /dev/null
		n c
	)" "$(
		cat <<-eof
		     1	2023-06-21T20:25:00+00:00
		     2	2023-06-21T20:25:00+00:00
		     3	2023-06-21T20:24:59+00:00
		eof
	)"
}; run-with-filter test--n--when-selecting-third

function test--n--when-selecting-last {
	assert "$(
		echo $input_with_tabs | ss > /dev/null
		n d
	)" "$(
		cat <<-eof
		     1	webhook-asg
		     2	webhook-asg
		     3	webhook-asg
		eof
	)"
}; run-with-filter test--n--when-selecting-last

function test--n--when-selecting-with-color {
	assert "$(
		echo $input_with_tabs | grep 00 | ss > /dev/null
		n d
	)" "$(
		cat <<-eof
		     1	webhook-asg
		     2	webhook-asg
		     3	webhook-asg
		eof
	)"
}; run-with-filter test--n--when-selecting-with-color

function test--n--when-selecting-out-of-bound {
	assert "$(
		echo $input_with_tabs | ss > /dev/null
		n z
	)" "$(
		cat <<-eof
		     1	10.0.0.1        # 2023-06-21T20:25:00+00:00     webhook-asg
		     2	10.0.0.2        # 2023-06-21T20:25:00+00:00     webhook-asg
		     3	10.0.0.3        # 2023-06-21T20:24:59+00:00     webhook-asg
			$(green-bg '        a               b c                             d          ')
		eof
	)"
}; run-with-filter test--n--when-selecting-out-of-bound

function test--n--with-kubectl-get-pods-output {
	local input=$(
		cat <<-eof
			pod-1           1/1     Running     1 (15h ago)        15h
			pod-2           1/1     Running     0                  7d14h
			pod-3           1/1     Running     312 (8d ago)       43d
			pod-4           1/1     Running     0                  14h
		eof
	)

	assert "$(
		echo $input | ss > /dev/null
		n e
	)" "$(
		cat <<-eof
		     1	15h
		     2	7d14h
		     3	43d
		     4	14h
		eof
	)"
}; run-with-filter test--n--with-kubectl-get-pods-output

function test--n--with-one-column {
	assert "$(
		echo $input | ss > /dev/null
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
}; run-with-filter test--n--with-one-column

function test--n--with-whitespace {
	assert "$(
		echo $input_with_whitespace | ss > /dev/null
		n a
	)" "$(
		cat <<-eof
		     1	  terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	  terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		eof
	)"
}; run-with-filter test--n--with-whitespace

function test--n--with-headers {
	assert "$(
		echo $input_with_headers | ss > /dev/null
		n
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
			$(green-bg '        a                                       b      c   d       e   f    g  ')
		eof
	)"
}; run-with-filter test--n--with-headers

function test--nn {
	assert "$(
		echo $input_with_headers | ss > /dev/null
		nn
	)" "$(
		cat <<-eof
		     1	MANIFEST                                COMMENT
		     2	terraform-application-region-shared-1   hello world
		     3	terraform-application-region-shared-2   foo bar
		     4	terraform-application-region-shared-3   sup
		     5	terraform-application-region-program-A  how are you
		     6	terraform-application-region-program-B  select via headers for this one
			$(green-bg '        a                                       b      ')
		eof
	)"
}; run-with-filter test--nn

function test--nn--with-one-column {
	assert "$(
		echo $input | ss > /dev/null
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
}; run-with-filter test--nn--with-one-column

function test--c {
	assert "$(
		echo $input | ss > /dev/null
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
}; run-with-filter test--c

function test--c--with-one-arg {
	assert "$(c '123'; pbpaste)" '123'
}; run-with-filter test--c--with-one-arg

function test--c--with-two-args {
	assert "$(c '123 321'; pbpaste)" '123 321'
}; run-with-filter test--c--with-two-args

function test--y {
	assert "$(
		echo $input | ss > /dev/null
		rm -f ~/.zshrc.args
		y
		cat ~/.zshrc.args
	)" "$input"
}; run-with-filter test--y

function test--p {
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
}; run-with-filter test--p

function test--u {
	assert "$(
		echo $input | ss > /dev/null
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
}; run-with-filter test--u

function test--u--when-undoing-n-with-headers {
	assert "$(
		echo $input_with_headers | ss > /dev/null
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
			$(green-bg '        a                                       b      c   d       e   f    g  ')
		eof
	)"
}; run-with-filter test--u--when-undoing-n-with-headers

function test--u--when-undoing-nn-with-headers {
	assert "$(
		echo $input_with_headers | ss > /dev/null
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
			$(green-bg '        a                                       b      ')
		eof
	)"
}; run-with-filter test--u--when-undoing-nn-with-headers

function test--u--when-undoing-nn-then-requesting-n {
	assert "$(
		echo $input_with_headers | ss > /dev/null
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
			$(green-bg '        a                                       b      c   d       e   f    g  ')
		eof
	)"
}; run-with-filter test--u--when-undoing-nn-then-requesting-n

function test--u--when-undoing-nn-with-headers-top-heavy {
	assert "$(
		echo $input_with_headers_top_heavy | ss > /dev/null
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
			$(green-bg '        a                                       b      ')
		eof
	)"
}; run-with-filter test--u--when-undoing-nn-with-headers-top-heavy

function test--u--when-undoing-ss-that-could-look-like-nn {
	assert "$(
		echo $input_with_headers | ss > /dev/null
		nn > /dev/null
		echo $input_with_headers_top_heavy | ss > /dev/null
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
}; run-with-filter test--u--when-undoing-ss-that-could-look-like-nn

function test--u--when-undoing-x2 {
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
}; run-with-filter test--u--when-undoing-x2

function test--u--when-undoing-beyond-tail {
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
		$(red-bg '  Reached the end of undo history  ')
		eof
	)"
}; run-with-filter test--u--when-undoing-beyond-tail

function test--u--when-pushing-beyond-head-then-undoing-beyond-tail {
	args-init
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
		$(red-bg '  Reached the end of undo history  ')
		eof
	)"

	args-init
}; run-with-filter test--u--when-pushing-beyond-head-then-undoing-beyond-tail

function test--u--when-undoing-then-redoing-with-color {
	assert "$(
		echo $input | ss > /dev/null
		a program > /dev/null
		u > /dev/null
		r
	)" "$(
		cat <<-eof
		     1	terraform-application-region-$(grep-color program)-A
		     2	terraform-application-region-$(grep-color program)-B
		eof
	)"
}; run-with-filter test--u--when-undoing-then-redoing-with-color

function test--u--when-undoing-then-redoing-then-undoing-again-with-color {
	assert "$(
		echo $input | ss > /dev/null
		a program > /dev/null
		u > /dev/null
		a terraform > /dev/null
		a application > /dev/null
		r > /dev/null
		u
	)" "$(
		cat <<-eof
		     1	terraform-$(grep-color application)-region-shared-1
		     2	terraform-$(grep-color application)-region-shared-2
		     3	terraform-$(grep-color application)-region-shared-3
		     4	terraform-$(grep-color application)-region-program-A
		     5	terraform-$(grep-color application)-region-program-B
		eof
	)"
}; run-with-filter test--u--when-undoing-then-redoing-then-undoing-again-with-color

function test--r--when-redoing-x2 {
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
}; run-with-filter test--r--when-redoing-x2

function test--r--when-redoing-beyond-head {
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
		$(red-bg '  Reached the end of redo history  ')
		eof
	)"
}; run-with-filter test--r--when-redoing-beyond-head

function test--r--when-redoing-beyond-new-head {
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
		$(red-bg '  Reached the end of redo history  ')
		eof
	)"
}; run-with-filter test--r--when-redoing-beyond-new-head

function test--i {
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
}; run-with-filter test--i

function test--i--when-selecting-out-of-head-and-tail {
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
}; run-with-filter test--i--when-selecting-out-of-head-and-tail

function test--i--when-selecting-head-index {
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
}; run-with-filter test--i--when-selecting-head-index

function test--i--when-selecting-middle-index {
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
}; run-with-filter test--i--when-selecting-middle-index

function test--i--when-selecting-tail-index {
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
}; run-with-filter test--i--when-selecting-tail-index

function test--save-args {
	assert "$(echo $input | save-args)" "$(
		cat <<-eof
		     1	terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		     5	terraform-application-region-program-B
		eof
	)"
}; run-with-filter test--save-args

function test--save-args--with-leading-whitespace {
	assert "$(echo $input_with_whitespace | save-args)" "$(
		cat <<-eof
		     1	  terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	  terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		eof
	)"
}; run-with-filter test--save-args--with-leading-whitespace

function test--save-args--with-hash-inserted {
	assert "$(echo $input_with_headers | save-args 'insert `#`')" "$(
		cat <<-eof
		     1	MANIFEST                                # COMMENT
		     2	terraform-application-region-shared-1   # hello world
		     3	terraform-application-region-shared-2   # foo bar
		     4	terraform-application-region-shared-3   # sup
		     5	terraform-application-region-program-A  # how are you
		     6	terraform-application-region-program-B  # select via headers for this one
		eof
	)"
}; run-with-filter test--save-args--with-hash-inserted