# shellcheck disable=SC1090,SC2015,SC2030,SC2031

source "$ZSHRC_DIR"/_tests/_harness.zsh
source "$ZSHRC_DIR"/_tests/_helpers.zsh

# Filter sections by number (1-5)
section_filter=$([[ $1 -ge 1 && $1 -le 5  ]] && echo "$1")

# Filter tests by partial name match
test_filter=$([[ -z $section_filter && -n $1 ]] && echo "$1")

# Source .zshrc for multiple sections
ZSHRC_UNDER_TEST=1 source ~/.zshrc

#
# 1: Run all test cases
#

if [[ $section_filter -eq 1 || -z $section_filter ]]; then
	echo
	if [[ -z $test_filter ]]; then
		echo '1: Run all test cases'
	else
		echo "1: Run test cases matching '*$test_filter*'"
	fi

	pasteboard=$(pbpaste) # Save pasteboard value since some tests overwrite it

	init

	for test in $(find-tests); do
		source "$test"
	done

	print-summary 'tests passed'

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

	for test in $(find-tests); do
		test_target="${test/_tests\/test_}"

		if [[ -f $test_target ]]; then
			verify-testing-order "$test_target" "$test"
		else
			verify-testing-order "$ZSHRC_DIR"/main.zsh "$test"
		fi
	done

	print-summary 'tests matched the testing order'
fi

#
# 4: Verify keymaps at the bottom of .zshrc are up-to-date
#

if [[ ($section_filter -eq 4 || -z $section_filter) && -z $test_filter ]]; then
	echo
	echo
	echo '4: Verify keymaps at the bottom of .zshrc are up-to-date'

	ruby "$ZSHRC_DIR"/_tests/verify_keymaps.rb
fi

#
# 5: Verify all env vars overwritten are getting restored
#

if [[ ($section_filter -eq 5 || -z $section_filter) && -z $test_filter ]]; then
	echo
	echo
	echo '5: Verify all env vars overwritten are getting restored'

	init

	expected=100
	[[ $ARGS_HISTORY_MAX -eq $expected ]] && pass || fail "ARGS_HISTORY_MAX: expected '$expected', got '$ARGS_HISTORY_MAX'"

	expected=1
	[[ $DD_CLEAR_TERMINAL -eq $expected ]] && pass || fail "DD_CLEAR_TERMINAL: expected '$expected', got '$DD_CLEAR_TERMINAL'"

	expected="$HOME/.zshrc.terminal-dump.d"
	[[ $DD_DUMP_DIR == "$expected" ]] && pass || fail "DD_DUMP_DIR: expected '$expected', got '$DD_DUMP_DIR'"

	expected="$HOME/.zsh_history"
	[[ $HISTFILE == "$expected" ]] && pass || fail "HISTFILE: expected '$expected', got '$HISTFILE'"

	expected='/Users/yzhao'
	[[ $HOME == "$expected" ]] && pass || fail "HOME: expected '$expected', got '$HOME'"

	print-summary 'env vars restored'
fi
