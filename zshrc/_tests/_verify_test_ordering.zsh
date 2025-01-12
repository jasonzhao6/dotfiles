function verify_test_ordering_section {
	local section_number=$1

	echo
	echo
	echo "$section_number: Verify subjects and tests are defined in the same order"

	init

	for test_file in $(find_test_files); do
		subject_file="${test_file/_tests\/test_}"
		verify_test_ordering "$subject_file" "$test_file"
	done

	print_summary 'subjects have tests, and the tests are defined in the same order as their subjects'
}

function verify_test_ordering {
	local subject_file=$1
	local test_file=$2

	# List all subject functions
	local subject_functions
	subject_functions=$(grep '^function' "$subject_file" | bw | sed 's/ {.*/ {/')

	# List all test functions
	local test_functions
	test_functions=$(grep '^function' "$test_file" | bw | sed -e 's/test__//' -e 's/__.*/ {/' | uniq)

	# Compare subject and test functions; note that `diff` returns nothing if the files are identical
	local functions_compared
	if [[ $subject_functions == "$test_functions" ]]; then
		functions_compared="$subject_functions"
	else
		functions_compared=$(diff -U999999 <(echo "$subject_functions") <(echo "$test_functions"))
	fi

	# Verify subject and test functions are defined in the same order
	while IFS= read -r subject; do
		# shellcheck disable=SC2076
		if [[ $subject =~ '^ *function' ]]; then
			pass
		elif [[ $subject =~ '^\+function' ]]; then
			fail "'$(echo "$subject" | trim 10 2)' does not match"
		fi
	done <<< "$functions_compared"
}
