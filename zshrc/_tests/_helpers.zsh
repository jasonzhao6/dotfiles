function find_tests {
	find "$ZSHRC_DIR/_tests" -name 'test_*.zsh'
}

function verify_ordering {
	local source; source=$(grep '^function' "$1" | sed 's/ {.*/ {/')
	local target; target=$(grep '^function' "$2" | sed -e 's/test__//' -e 's/__.*/ {/' | uniq)

	diff -U999999 <(echo "$source") <(echo "$target") | bw | while IFS= read -r line; do
		# shellcheck disable=SC2076
		if [[ $line =~ '^ function' ]]; then
			pass
		elif [[ $line =~ '^\+function' ]]; then
			fail "'$(echo "$line" | trim 10 2)' does not match"
		fi
	done
}

# Emulate grep coloring
function grep_color { echo "\e[1;32m\e[K$*\e[m\e[K"; }
function pgrep_color { echo "\e[1;32m$*\e[00m"; }
