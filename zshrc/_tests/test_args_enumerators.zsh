test__input=$(
	cat <<-eof
		terraform-application-region-shared-1
		terraform-application-region-shared-2
		terraform-application-region-shared-3
		terraform-application-region-program-A
		terraform-application-region-program-B
	eof
)

test__input_with_comments=$(
	cat <<-eof
		10.0.0.1	# 2023-06-21T20:25:00+00:00	webhook-asg
		10.0.0.2	# 2023-06-21T20:25:00+00:00	webhook-asg
		10.0.0.3	# 2023-06-21T20:24:59+00:00	webhook-asg
	eof
)

function test__all {
	function test__all__sleep_and_echo { sleep "$@"; echo "$@"; }

	assert "$(
		printf '0.01\n0.03\n0.05' | args_keymap_s > /dev/null
		all test__all__sleep_and_echo 2> /dev/null
	)" "$(
		cat <<-eof

			0.01
			0.03
			0.05
		eof
	)"
}; run_with_filter test__all

function test__each {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
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
		echo "$test__input_with_comments" | args_keymap_s > /dev/null
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

function test__map {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
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
	assert "$(
		seq 1 5 | args_keymap_s > /dev/null
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
