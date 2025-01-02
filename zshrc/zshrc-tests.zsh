source $ZSHRC_DIR/zshrc-tests/harness.zsh
source $ZSHRC_DIR/zshrc-tests/helpers.zsh

# $1: Filter tests by partial name match
local filter=$([[ -n $1 ]] && echo $1)

#
# Section 1: Run all test cases
#

local pasteboard=$(pbpaste) # Save pasteboard value since some tests overwrite it

init
UNDER_TEST=1 source ~/.zshrc
for test in $(find-tests); do source $test; done
print-summary 'tests passed'

echo $pasteboard | pbcopy # Restore saved pasteboard value

#
# Section 2: Verify all tests defined are getting invoked
#

[[ -z $filter ]] && { echo; ruby $ZSHRC_DIR/zshrc-tests/verify_test_invocations.rb }

#
# Section 3: Verify tests are defined in the same order as their definitions in .zshrc
#

if [[ -z $filter ]]; then
	echo
	init
	for test in $(find-tests); do
		# TODO temp conditional
		if [[ $test =~ 'zsh-t' ]]; then
			verify-testing-order $ZSHRC_DIR/zshrc-t.zsh $test
		else
			verify-testing-order $ZSHRC_DIR/zshrc.zsh $test
		fi
	done
	print-summary 'tests matched the testing order'
fi

#
# Section 4: Verify keymaps at the bottom of .zshrc are up-to-date
#

[[ -z $filter ]] && { echo; ruby $ZSHRC_DIR/zshrc-tests/verify_keymaps.rb }

#
# Section 5: Verify all env vars overwritten are getting restored
#

if [[ -z $filter ]]; then
	echo
	init
	local expected=

	expected=100
	[[ $ARGS_HISTORY_MAX -eq $expected ]] && pass || fail "ARGS_HISTORY_MAX: expected '$expected', got '$ARGS_HISTORY_MAX'"

	expected=1
	[[ $DD_CLEAR_TERMINAL -eq $expected ]] && pass || fail "DD_CLEAR_TERMINAL: expected '$expected', got '$DD_CLEAR_TERMINAL'"

	expected="$HOME/.zshrc.terminal-dump.d"
	[[ $DD_DUMP_DIR == $expected ]] && pass || fail "DD_DUMP_DIR: expected '$expected', got '$DD_DUMP_DIR'"

	expected="$HOME/.zsh_history"
	[[ $HISTFILE == $expected ]] && pass || fail "HISTFILE: expected '$expected', got '$HISTFILE'"

	expected='/Users/yzhao'
	[[ $HOME == $expected ]] && pass || fail "HOME: expected '$expected', got '$HOME'"

	print-summary 'env vars restored'
fi
