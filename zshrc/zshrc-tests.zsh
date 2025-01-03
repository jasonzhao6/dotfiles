source "$ZSHRC_DIR"/zshrc-tests/harness.zsh
source "$ZSHRC_DIR"/zshrc-tests/helpers.zsh

# $1: Filter tests by partial name match
test_filter=$([[ -n $1 ]] && echo "$1")

# Filter sections by number, leave it unset usually
section_filter=

# Source .zshrc for multiple sections that need it
# shellcheck source="$HOME/.zshrc"
UNDER_TEST=1 source ~/.zshrc

#
# Section 1: Run all test cases
#

if [[ $section_filter -eq 1 || -z $section_filter ]]; then
	pasteboard=$(pbpaste) # Save pasteboard value since some tests overwrite it

	init

	for test in $(find-tests); do
		# shellcheck source=/dev/null
		source "$test"
	done

	print-summary 'tests passed'

	echo "$pasteboard" | pbcopy # Restore saved pasteboard value
fi

#
# Section 2: Verify all tests defined are getting invoked
#

if [[ ($section_filter -eq 2 || -z $section_filter) && -z $test_filter ]]; then
	echo
	ruby "$ZSHRC_DIR"/zshrc-tests/verify_test_invocations.rb
fi

#
# Section 3: Verify tests are defined in the same order as their definitions in .zshrc
#

if [[ ($section_filter -eq 3 || -z $section_filter) && -z $test_filter ]]; then
	echo
	init
	for test in $(find-tests); do
		if [[ $test =~ zshrc-[to].zsh ]]; then
			verify-testing-order "${test/zshrc-tests\/test-}" "$test"
		else
			verify-testing-order "$ZSHRC_DIR"/zshrc.zsh "$test"
		fi
	done
	print-summary 'tests matched the testing order'
fi

#
# Section 4: Verify keymaps at the bottom of .zshrc are up-to-date
#

if [[ ($section_filter -eq 4 || -z $section_filter) && -z $test_filter ]]; then
	echo
	ruby "$ZSHRC_DIR"/zshrc-tests/verify_keymaps.rb
fi

#
# Section 5: Verify all env vars overwritten are getting restored
#

# shellcheck disable=SC2015
if [[ ($section_filter -eq 5 || -z $section_filter) && -z $test_filter ]]; then
	echo
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
