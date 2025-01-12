function verify_test_invocations_section {
	local section_number=$1

	echo
	echo
	echo "$section_number: Verify all tests defined are also invoked"

	init

	for test_file in $(find_test_files); do
		verify_test_invocations "$test_file"
	done

	print_summary 'tests were defined and invoked'
}

function verify_test_invocations {
	local test_file=$1

	local prefix

	# List all test definitions
	prefix='function'
	local test_definitions; test_definitions=$(
		grep "^$prefix" "$test_file" | bw | sed -e "s/$prefix //" -e 's/ {.*//'
	)

	# List all test invocations
	prefix='}; run_with_filter'
	local test_invocations; test_invocations=$(
		grep "^$prefix" "$test_file" | bw | sed -e "s/$prefix //" -e 's/ {.*//'
	)

	# Compare definitions and invocations; note that `diff` returns nothing if the files are identical
	local tests_compared
	if [[ $test_definitions == "$test_invocations" ]]; then
		tests_compared="$test_definitions"
	else
		tests_compared=$(diff -U999999 <(echo "$test_definitions") <(echo "$test_invocations") | bw)
	fi

	# Verify all tests defined are also invoked
	while IFS= read -r diff; do
		# shellcheck disable=SC2076
		if [[ $diff =~ '^ ?test__' ]]; then
			pass
		elif [[ $diff =~ '^[-+]test__' ]]; then
			fail "'$(echo "$diff" | trim 1)' does not match"
		fi
	done <<< "$tests_compared"
}
