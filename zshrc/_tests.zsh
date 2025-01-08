export ZSHRC_TESTS_DIR="$ZSHRC_DIR/_tests"

source "$ZSHRC_DIR"/_tests/_harness.zsh
source "$ZSHRC_DIR"/_tests/_helpers.zsh

# Filter sections by number (1-5)
section_filter=$([[ $1 -ge 1 && $1 -le 5 ]] && echo "$1")

# Filter tests by substring match
# shellcheck disable=SC2030
test_filter=$([[ -z $section_filter && -n $1 ]] && echo "$1")

# Source .zshrc for multiple sections
ZSHRC_UNDER_TEST=1 source ~/.zshrc

#
# 1: Run all test cases
#

# shellcheck disable=SC2031
if [[ $section_filter -eq 1 || -z $section_filter ]]; then
	echo

	if [[ -z $test_filter ]]; then
		echo '1: Run all test cases'
	else
		echo "1: Run test cases matching \`*$test_filter*\`"
	fi

	pasteboard=$(pbpaste) # Save pasteboard value since some tests overwrite it

	init
	for test in $(find_tests); do source "$test"; done
	print_summary 'tests passed'

	echo "$pasteboard" | pbcopy # Restore saved pasteboard value
fi

#
# 2: Verify all tests defined are getting invoked
#

if [[ ($section_filter -eq 2 || -z $section_filter) && -z $test_filter ]]; then
	echo
	echo
	echo '2: Verify all tests defined are getting invoked'

	ruby "$ZSHRC_DIR"/_tests/verify_test_invocations.rb
fi

#
# 3: Verify tests are defined in the same order as their definitions
#

if [[ ($section_filter -eq 3 || -z $section_filter) && -z $test_filter ]]; then
	echo
	echo
	echo '3: Verify tests are defined in the same order as their definitions'

	init

	for test in $(find_tests); do
		test_target="${test/_tests\/test_}"

		if [[ -f $test_target ]]; then
			verify_ordering "$test_target" "$test"
		else
			verify_ordering "$ZSHRC_DIR"/main.zsh "$test"
		fi
	done

	print_summary 'tests matched the function ordering'
fi

#
# 4: Verify keymaps at the bottom of .zshrc are up-to-date
#

#if [[ ($section_filter -eq 4 || -z $section_filter) && -z $test_filter ]]; then
#	echo
#	echo
#	echo '4: Verify keymaps at the bottom of .zshrc are up-to-date'
#
#	ruby "$ZSHRC_DIR"/_tests/verify_keymaps.rb
#fi

# TODO ^ uncomment
# TODO are keymap functions alphabetized?
