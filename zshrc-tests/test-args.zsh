input=$(
	cat <<-eof
		terraform-application-region-shared-1
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

function test_vv {
	local output=$(
		echo $input | pbcopy
		vv
	)

	local expected=$(
		cat <<-eof
			     1	terraform-application-region-shared-1
			     2	terraform-application-region-shared-2
			     3	terraform-application-region-shared-3
			     4	terraform-application-region-program-A
			     5	terraform-application-region-program-B
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_vv'
}; test_vv

function test_ss {
	# Cannot test b/c `fc -l` throws 'no such event' error
}

function test_aa_when-0-arg {
	local output=$(
		echo $input | save-args > /dev/null
		aa
	)

	local expected=$(
		cat <<-eof
			     1	terraform-application-region-shared-1
			     2	terraform-application-region-shared-2
			     3	terraform-application-region-shared-3
			     4	terraform-application-region-program-A
			     5	terraform-application-region-program-B
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_aa_when-0-arg'
}; test_aa_when-0-arg

function test_aa_when-1-arg {
	local output=$(
		echo $input | save-args > /dev/null
		aa shared | no-color
	)

	local expected=$(
		cat <<-eof
			     1	terraform-application-region-shared-1
			     2	terraform-application-region-shared-2
			     3	terraform-application-region-shared-3
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_aa_when-1-arg'
}; test_aa_when-1-arg

function test_aa_when-2-args-out-of-order {
	local output=$(
		echo $input | save-args > /dev/null
		aa 2 shared | no-color
	)

	local expected=$(
		cat <<-eof
			     1	terraform-application-region-shared-2
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_aa_when-2-args-out-of-order'
}; test_aa_when-2-args-out-of-order

function test_aa_when-2-args-including-negative {
	local output=$(
		echo $input | save-args > /dev/null
		aa -2 shared | no-color
	)

	local expected=$(
		cat <<-eof
			     1	terraform-application-region-shared-1
			     2	terraform-application-region-shared-3
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_aa_when-2-args-including-negative'
}; test_aa_when-2-args-including-negative

function test_arg_when-2 {
	local output=$(
		echo $input | save-args > /dev/null
		arg 2 echo 2>&1
	)

	local expected=$(
		cat <<-eof
			echo terraform-application-region-shared-2
			terraform-application-region-shared-2
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_arg_when-2'
}; test_arg_when-2

function test_arg_when-3 {
	local output=$(
		echo $input | save-args > /dev/null
		arg 3 echo 2>&1
	)

	local expected=$(
		cat <<-eof
			echo terraform-application-region-shared-3
			terraform-application-region-shared-3
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_arg_when-3'
}; test_arg_when-3

function test_each {
	local output=$(
		echo $input | save-args > /dev/null
		each echo 2>&1
	)

	local expected=$(
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
	)

	[[ $output == $expected ]] && pass || fail 'test_each'
}; test_each

function test_each_when-with-tabs {
	local input=$(
		cat <<-eof
			row-1	# tab
			row-2
			row-3	# tab
		eof
	)

	local output=$(
		echo $input | save-args > /dev/null
		each echo 2>&1
	)

	local expected=$(
		cat <<-eof

			echo row-1	# tab
			row-1

			echo row-2
			row-2

			echo row-3	# tab
			row-3
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_each_when-with-tabs'
}; test_each_when-with-tabs

function test_map {
	local output=$(
		echo $input | save-args > /dev/null
		map echo 2>&1
	)

	local expected=$(
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

			     1	terraform-application-region-shared-1
			     2	terraform-application-region-shared-2
			     3	terraform-application-region-shared-3
			     4	terraform-application-region-program-A
			     5	terraform-application-region-program-B
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_map'
}; test_map

function test_a {
	local output=$(
		echo $input | save-args > /dev/null
		a echo 2>&1
	)

	local expected=$(
		cat <<-eof
			echo terraform-application-region-shared-1
			terraform-application-region-shared-1
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_a'
}; test_a

function test_1 {
	local output=$(
		echo $input | save-args > /dev/null
		1 echo 2>&1
	)

	local expected=$(
		cat <<-eof
			echo terraform-application-region-shared-1
			terraform-application-region-shared-1
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_1'
}; test_1

function test_5 {
	local output=$(
		echo $input | save-args > /dev/null
		5 echo 2>&1
	)

	local expected=$(
		cat <<-eof
			echo terraform-application-region-program-B
			terraform-application-region-program-B
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_5'
}; test_5

function test_6 {
	local output=$(
		echo $input | save-args > /dev/null
		6 echo 2>&1
	)

	local expected='echo '

	[[ $output == $expected ]] && pass || fail 'test_6'
}; test_6

function test_0 {
	local output=$(
		echo $input | save-args > /dev/null
		0 echo 2>&1
	)

	local expected=$(
		cat <<-eof
			echo terraform-application-region-program-B
			terraform-application-region-program-B
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_0'
}; test_0

function test_s {
	local output=$(
		echo $input | save-args > /dev/null
		s echo 2>&1
	)

	local expected=$(
		cat <<-eof
			echo terraform-application-region-program-B
			terraform-application-region-program-B
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_s'
}; test_s

function test_rr {
	local output=$(
		echo $input | save-args > /dev/null
		aa program > /dev/null
		rr
	)

	local expected=$(
		cat <<-eof
			     1	terraform-application-region-shared-1
			     2	terraform-application-region-shared-2
			     3	terraform-application-region-shared-3
			     4	terraform-application-region-program-A
			     5	terraform-application-region-program-B
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_rr'
}; test_rr

function test_rr_when-reverting-revert {
	local output=$(
		echo $input | save-args > /dev/null
		aa program > /dev/null
		rr > /dev/null
		rr | no-color
	)

	local expected=$(
		cat <<-eof
			     1	terraform-application-region-program-A
			     2	terraform-application-region-program-B
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_rr_when-reverting-revert'
}; test_rr_when-reverting-revert

function test_rr_when-reverting-xx {
	local output=$(
		echo $input | save-args > /dev/null
		xx 10 > /dev/null
		rr
	)

	local expected=$(
		cat <<-eof
			     1	terraform-application-region-shared-1
			     2	terraform-application-region-shared-2
			     3	terraform-application-region-shared-3
			     4	terraform-application-region-program-A
			     5	terraform-application-region-program-B
			        0    •    1    •    2    •    3    •
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_rr_when-reverting-xx'
}; test_rr_when-reverting-xx

function test_xx_when-at-threshold {
	local output=$(
		echo 01234567890 | save-args > /dev/null
		xx
	)

	local expected=$(
		cat <<-eof
			     1	01234567890
			        0    •    1
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_xx_when-at-threshold'
}; test_xx_when-at-threshold

function test_xx_when-above-threshold {
	local output=$(
		echo 012345678901 | save-args > /dev/null
		xx
	)

	local expected=$(
		cat <<-eof
			     1	012345678901
			        0    •    1
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_xx_when-above-threshold'
}; test_xx_when-above-threshold

function test_xx_when-below-threshold {
	local output=$(
		echo 0123456789 | save-args > /dev/null
		xx
	)

	local expected=$(
		cat <<-eof
			     1	0123456789
			        0    •
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_xx_when-below-threshold'
}; test_xx_when-below-threshold

function test_xx_when-0-arg {
	local output=$(
		echo $input | save-args > /dev/null
		xx
	)

	local expected=$(
		cat <<-eof
			     1	terraform-application-region-shared-1
			     2	terraform-application-region-shared-2
			     3	terraform-application-region-shared-3
			     4	terraform-application-region-program-A
			     5	terraform-application-region-program-B
			        0    •    1    •    2    •    3    •
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_xx_when-0-arg'
}; test_xx_when-0-arg

function test_xx_when-1-arg {
	local output=$(
		echo $input | save-args > /dev/null
		xx 9
	)

	local expected=$(
		cat <<-eof
			     1	-application-region-shared-1
			     2	-application-region-shared-2
			     3	-application-region-shared-3
			     4	-application-region-program-A
			     5	-application-region-program-B
			        0    •    1    •    2    •
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_xx_when-1-arg'
}; test_xx_when-1-arg

function test_xx_when-2-args {
	local output=$(
		echo $input | save-args > /dev/null
		xx 9 1
	)

	local expected=$(
		cat <<-eof
			     1	-application-region-shared-
			     2	-application-region-shared-
			     3	-application-region-shared-
			     4	-application-region-program-
			     5	-application-region-program-
			        0    •    1    •    2    •
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_xx_when-2-args'
}; test_xx_when-2-args

function test_xx_when-0-arg-with-tabs {
	local output=$(
		echo $input_with_tabs | save-args > /dev/null
		xx
	)

	local expected=$(
		cat <<-eof
			     1	10.0.0.1	# 2023-06-21T20:25:00+00:00	webhook-asg
			     2	10.0.0.2	# 2023-06-21T20:25:00+00:00	webhook-asg
			     3	10.0.0.3	# 2023-06-21T20:24:59+00:00	webhook-asg
			        0    •    1    •    2    •    3    •    4    •    5    •
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_xx_when-0-arg-with-tabs'
}; test_xx_when-0-arg-with-tabs

function test_xx_when-1-arg-with-tabs {
	local output=$(
		echo $input_with_tabs | save-args > /dev/null
		xx 48
	)

	local expected=$(
		cat <<-eof
			     1	webhook-asg
			     2	webhook-asg
			     3	webhook-asg
			        0    •    1
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_xx_when-1-arg-with-tabs'
}; test_xx_when-1-arg-with-tabs

function test_xx_when-2-args-with-tabs {
	local output=$(
		echo $input_with_tabs | save-args > /dev/null
		xx 18 16
	)

	local expected=$(
		cat <<-eof
			     1	2023-06-21T20:25:00+00:00
			     2	2023-06-21T20:25:00+00:00
			     3	2023-06-21T20:24:59+00:00
			        0    •    1    •    2
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_xx_when-2-args-with-tabs'
}; test_xx_when-2-args-with-tabs

function test_yy {
	local output=$(
		echo $input | save-args > /dev/null
		rm ~/.zshrc.args
		yy
		cat ~/.zshrc.args
	)

	[[ $output == $input ]] && pass || fail 'test_yy'
}; test_yy

function test_pp {
	local output=$(
		seq 3 > ~/.zshrc.args
		pp
	)

	local expected=$(
		cat <<-eof
			     1	1
			     2	2
			     3	3
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_pp'
}; test_pp

function test_c_when-0-arg {
	local output=$(
		echo $input | save-args > /dev/null
		c
		pbpaste
	)

	local expected=$(
		cat <<-eof
			terraform-application-region-shared-1
			terraform-application-region-shared-2
			terraform-application-region-shared-3
			terraform-application-region-program-A
			terraform-application-region-program-B
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_c_when-0-arg'
}; test_c_when-0-arg

function test_c_when-1-arg {
	local input='123'
	local output=$(c $input; pbpaste)
	local expected=$input

	[[ $output == $expected ]] && pass || fail 'test_c_when-1-arg'
}; test_c_when-1-arg

function test_c_when-2-args {
	local input='123 321'
	local output=$(c $input; pbpaste)
	local expected=$input

	[[ $output == $expected ]] && pass || fail 'test_c_when-2-args'
}; test_c_when-2-args

function test_args_when_color {
	local output=$(
		echo $input | grep region | save-args > /dev/null
		args
	)

	local expected=$(
		cat <<-eof
			terraform-application-region-shared-1
			terraform-application-region-shared-2
			terraform-application-region-shared-3
			terraform-application-region-program-A
			terraform-application-region-program-B
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_args_when_color'
}; test_args_when_color

function test_angs-list {
	local output=$(
		echo $input | save-args > /dev/null
		args-list
	)

	local expected=$(
		cat <<-eof
			     1	terraform-application-region-shared-1
			     2	terraform-application-region-shared-2
			     3	terraform-application-region-shared-3
			     4	terraform-application-region-program-A
			     5	terraform-application-region-program-B
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_angs-list'
}; test_angs-list

function test_args-ruler {
	local output=$(
		echo $input | save-args > /dev/null
		args-ruler
	)

	local expected=$(
		cat <<-eof
			        0    •    1    •    2    •    3    •
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_args-ruler'
}; test_args-ruler

function test_greps {
	local output=$(
		greps -aa bb -cc
		echo $GREPS
	)

	local expected=$(
		cat <<-eof
			grep --color=never --ignore-case --invert-match aa | grep --color=never --ignore-case bb | grep --color=never --ignore-case --invert-match cc
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_greps'
}; test_greps

function test_prev-command {
	# Cannot test b/c `fc -l` throws 'no such event' error
}

function test_save-args_when-0-arg {
	local output=$(echo $input | save-args)

	local expected=$(
		cat <<-eof
			     1	terraform-application-region-shared-1
			     2	terraform-application-region-shared-2
			     3	terraform-application-region-shared-3
			     4	terraform-application-region-program-A
			     5	terraform-application-region-program-B
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_save-args_when-0-arg'
}; test_save-args_when-0-arg

function test_save-args_when-1-arg {
	local output=$(echo $input | save-args 2)

	local expected=$(
		cat <<-eof
			     1	terraform-application-region-shared-1
			     2	terraform-application-region-shared-2
		eof
	)

	[[ $output == $expected ]] && pass || fail 'test_save-args_when-1-arg'
}; test_save-args_when-1-arg
