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
	local sync_dir; sync_dir=$(mktemp -d)

	# Fix for flaky test / race condition: instead of racing 3 independent
	# `sleep` wake-ups, chain each release to the prior turn's actual completion
	(
		while [[ ! -f "$sync_dir/1.done" ]]; do sleep 0.01; done
		touch "$sync_dir/2"
		while [[ ! -f "$sync_dir/2.done" ]]; do sleep 0.01; done
		touch "$sync_dir/3"
	) &
	local releaser_pid=$!

	# shellcheck disable=SC2317 # invoked by name via `all` (the enumerator under test), not directly
	function test__all__wait_for_turn {
		local turn=$1

		# The first turn isn't gated; it just marks itself done when finished
		[[ $turn != 1 ]] && while [[ ! -f "$sync_dir/$turn" ]]; do sleep 0.01; done

		echo "$turn"
		touch "$sync_dir/$turn.done"
	}

	assert "$(
		printf '1\n2\n3' | args_keymap_s > /dev/null
		all test__all__wait_for_turn 2> /dev/null
	)" "$(
		cat <<-eof

			1
			2
			3
		eof
	)"

	wait $releaser_pid 2>/dev/null
	rm -rf "$sync_dir"
}

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
}

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
}

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
}

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
}
