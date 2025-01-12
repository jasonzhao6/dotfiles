export ZSHRC_TESTS_DIR="$ZSHRC_DIR/_tests"

source "$ZSHRC_DIR"/_tests/_test_harness.zsh
source "$ZSHRC_DIR"/_tests/_test_helpers.zsh

# Filter sections by number (1-5)
ZSHRC_TESTS_SECTION_FILTER=$([[ $1 -ge 1 && $1 -le 5 ]] && echo "$1")

# Filter tests by substring match
# shellcheck disable=SC2030
ZSHRC_TESTS_NAME_FILTER=$([[ -z $ZSHRC_TESTS_SECTION_FILTER && -n $1 ]] && echo "$1")

# Source test subjects and general utils
ZSHRC_UNDER_TESTING=1 source ~/.zshrc

#
# 1: Run all test cases
#

# shellcheck disable=SC2031
if [[ $ZSHRC_TESTS_SECTION_FILTER -eq 1 || -z $ZSHRC_TESTS_SECTION_FILTER ]]; then

	echo
	if [[ -z $ZSHRC_TESTS_NAME_FILTER ]]; then
		echo '1: Run all test cases'
	else
		echo "1: Run test cases matching \`*$ZSHRC_TESTS_NAME_FILTER*\`"
	fi

	pasteboard=$(pbpaste) # Save pasteboard value since some tests overwrite it

	init
	for test in $(find_test_files); do source "$test"; done
	print_summary 'tests passed'

	echo "$pasteboard" | pbcopy # Restore saved pasteboard value
fi

#
# 2: Verify all tests defined are getting invoked
#

if [[ ($ZSHRC_TESTS_SECTION_FILTER -eq 2 || -z $ZSHRC_TESTS_SECTION_FILTER) && -z $ZSHRC_TESTS_NAME_FILTER ]]; then
	echo
	echo
	echo '2: Verify all tests defined are getting invoked'

	ruby "$ZSHRC_DIR"/_tests/verify_test_invocations.rb
fi

#
# 3: Verify subjects and tests are defined in the same order
#

if [[ ($ZSHRC_TESTS_SECTION_FILTER -eq 3 || -z $ZSHRC_TESTS_SECTION_FILTER) && -z $ZSHRC_TESTS_NAME_FILTER ]]; then
	echo
	echo
	echo '3: Verify subjects and tests are defined in the same order'

	init

	for test_file in $(find_test_files); do
		subject_file="${test_file/_tests\/test_}"
		verify_ordering "$subject_file" "$test_file"
	done

	print_summary 'subjects have tests, and the tests are defined in the same order as their subjects'
fi

#
# 4: Verify key mapping functions in keymaps are alphabetized # TODO
#
