# Test config
local filter=$([[ -n $1 ]] && echo $1)

# Test helpers
function init {
	passes=0
	total=0
	failed=''
	debug=''
}
function pass {
	((passes++))
	((total++))
	echo -n .
}
function fail {
	local name=$1

	failed+="\nfail: $name"
	((total++))
	echo -n f

	debug+="\n\ndebug: $name\n"
	debug+=$(diff -u <(echo $expected) <(echo $output) | sed '/--- /d; /+++ /d; /@@ /d')
}
function assert {
	local output=$1
	local expected=$2

	[[ $output == $expected ]] && pass || fail "'$funcstack[2]'"
}
function find-tests {
	find ~/gh/dotfiles/zshrc-tests -name '*.zsh'
}
function run-with-filter {
	[[ -z $filter || $(index-of $@ $filter) -ne 0 ]] && $@
}
function verify-test-ordering {
	local source=$(grep '^function' $1 | sed 's/ {.*/ {/')
	local target=$(grep '^function' $2 | sed -e 's/test--//' -e 's/--[^-].*/ {/' | uniq)

	diff -U999999 <(echo $source) <(echo $target) | no-color | while IFS= read -r line; do
		if [[ $line =~ '^ function' ]]; then
			pass
		elif [[ $line =~ '^\+function' ]]; then
			fail "'$(echo "$line" | trim 10 2)' does not match"
		fi
	done
}

#
# Section 1: Run test cases
#

init
local pasteboard=$(pbpaste) # Save pasteboard value since some tests overwrite it

source ~/gh/dotfiles/zshrc.zsh
for test in $(find-tests); do source $test; done

args-init # Reset args history since some tests overwrote it
echo $pasteboard | pbcopy # Restore saved pasteboard value

echo "\n($passes/$total tests passed)"
[[ $passes -ne $total ]] && echo $failed $debug

#
# Section 2: Verify all tests defined are getting invoked
#

[[ -z $filter ]] && { echo; ruby ~/gh/dotfiles/zshrc-tests/verify_test_invocations.rb }

#
# Section 3: Verify tests are defined in the same order as their definitions in .zshrc
#

if [[ -z $filter ]]; then
	init
	echo

	for test in $(find-tests); do verify-test-ordering ~/gh/dotfiles/zshrc.zsh $test; done

	echo "\n($passes/$total functions matched the testing order)"
	[[ $passes -ne $total ]] && echo $failed
fi

#
# Section 4: Verify keymaps at the bottom of .zshrc are up-to-date
#

[[ -z $filter ]] && { echo; ruby ~/gh/dotfiles/zshrc-tests/verify_keymaps.rb }

#
# Section 5: Verify all env vars overwritten are getting restored
#

if [[ -z $filter ]]; then
	init
	echo

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

	echo "\n($passes/$total env vars were restored)"
	[[ $passes -ne $total ]] && echo $failed
fi
