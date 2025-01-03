function find-tests {
	find "$ZSHRC_DIR/_tests" -name 'test_*.zsh'
}

function verify-testing-order {
	local source; source=$(grep '^function' "$1" | sed 's/ {.*/ {/')
	local target; target=$(grep '^function' "$2" | sed -e 's/test__//' -e 's/__.*/ {/' | uniq)

	diff -U999999 <(echo "$source") <(echo "$target") | no_color | while IFS= read -r line; do
		# shellcheck disable=SC2076
		if [[ $line =~ '^ function' ]]; then
			pass
		elif [[ $line =~ '^\+function' ]]; then
			fail "'$(echo "$line" | trim 10 2)' does not match"
		fi
	done
}
