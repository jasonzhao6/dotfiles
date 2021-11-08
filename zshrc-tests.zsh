# Test config
filter= # <empty> or <partial name match>

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
function run-with-filter {
	[[ -z $filter || $(index-of $@ $filter) -ne 0 ]] && $@
}
function green-fg {
	echo "[1;32m[K$@[m[K"
}
function green-bg {
	echo "\e[42m$@\e[0m"
}
function verify-order {
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

# Load test subject
source ~/gh/dotfiles/zshrc.zsh

# Run test cases
init
local clipboard=$(pbpaste) # Save clipboard value since some tests overwrite it
source ~/gh/dotfiles/zshrc-tests/test-args.zsh
source ~/gh/dotfiles/zshrc-tests/test-change-dir.zsh
source ~/gh/dotfiles/zshrc-tests/test-github-helpers.zsh
source ~/gh/dotfiles/zshrc-tests/test-util.zsh
echo $clipboard | pbcopy # Restore clipboard value

# Print results
echo "\n($passes/$total tests passed)"
[[ $passes -ne $total ]] && echo $failed $debug

# Verify test order matches .zshrc
if [[ -z $filter ]]; then
	echo
	init
	verify-order ~/gh/dotfiles/zshrc.zsh ~/gh/dotfiles/zshrc-tests/test-args.zsh
	verify-order ~/gh/dotfiles/zshrc.zsh ~/gh/dotfiles/zshrc-tests/test-change-dir.zsh
	verify-order ~/gh/dotfiles/zshrc.zsh ~/gh/dotfiles/zshrc-tests/test-github-helpers.zsh
	verify-order ~/gh/dotfiles/zshrc.zsh ~/gh/dotfiles/zshrc-tests/test-util.zsh

	# Print results
	echo "\n($passes/$total functions match the test order)"
	[[ $passes -ne $total ]] && echo $failed
fi

# Verify keymaps in .zshrc point to the correct files and print results
[[ -z $filter ]] && { echo; ruby ~/gh/dotfiles/zshrc-tests/verify_keymaps.rb }
