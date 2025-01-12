function verify_ordering {
	local source; source=$(grep --color=never '^function' "$1" | sed 's/ {.*/ {/')
	local target; target=$(grep --color=never '^function' "$2" | sed -e 's/test__//' -e 's/__.*/ {/' | uniq)

	diff -U999999 <(echo "$source") <(echo "$target") | while IFS= read -r line; do
		# shellcheck disable=SC2076
		if [[ $line =~ '^ function' ]]; then
			pass
		elif [[ $line =~ '^\+function' ]]; then
			fail "'$(echo "$line" | trim 10 2)' does not match"
		fi
	done
}
