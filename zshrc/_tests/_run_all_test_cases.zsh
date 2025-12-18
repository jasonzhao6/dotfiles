function run_all_test_cases_section {
	local section_number=$1

	if [[ -z $ZSHRC_TESTS_NAME_FILTER ]]; then
		printf "\n%s: Run all test cases\n" "$section_number"
	else
		printf "\n%s: Run test cases matching \`*%s*\`\n" "$section_number" "$ZSHRC_TESTS_NAME_FILTER"
	fi

	pasteboard=$(pbpaste) # Save pasteboard value since some tests overwrite it

	init
	for test in $(find_test_files); do source "$test"; done
	execute_tests
	print_summary 'tests passed'

	echo "$pasteboard" | pbcopy # Restore saved pasteboard value
}
