# Save: Copy/paste for debugging
: '
	# DEBUGGING STARTS
	echo
	echo $output
	echo ---
	echo $expected
	echo ---
	# DEBUGGING ENDS
'

# Test helpers
failed=''
passes=0
total=0
function pass {
	((passes++))
	((total++))
	echo -n .
}
function fail {
	failed+="\nf: $@"
	((total++))
	echo -n f
}

# Source the test subject
source ~/.zshrc

# Source the test cases
source ~/gh/dotfiles/zshrc-tests/test-args.zsh
source ~/gh/dotfiles/zshrc-tests/test-change-dir.zsh
source ~/gh/dotfiles/zshrc-tests/test-github-helpers.zsh
source ~/gh/dotfiles/zshrc-tests/test-util.zsh

# When done, print test results
echo "\n($passes/$total tests passed)"
[[ $passes -ne $total ]] && echo $failed
