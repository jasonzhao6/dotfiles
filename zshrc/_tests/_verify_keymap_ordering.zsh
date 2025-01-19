function verify_keymap_ordering_section {
	local section_number=$1

	echo
	echo
	echo "$section_number: Verify key mapping functions are alphabetized"

	init

	for keymap_file in $(find_keymap_files); do
		verify_keymap_ordering "$keymap_file"
	done

	print_summary 'key mapping functions are alphabetized'
}

function verify_keymap_ordering {
	local keymap_file=$1

	# Find all key mapping functions
	local mapping_functions; mapping_functions=$(
		grep '^function' "$keymap_file" | bw | sed 's/ {.*//' | downcase
	)

	# Sort all key mapping functions
	local sorted_functions; sorted_functions=$(echo "$mapping_functions" | sort)

	# Check if functions are sorted; note that `diff` returns nothing if the files are identical
	local functions_compared
	if [[ $mapping_functions == "$sorted_functions" ]]; then
		functions_compared="$mapping_functions"
	else
		functions_compared=$(
			diff -U999999 <(echo "$mapping_functions") <(echo "$sorted_functions") | bw
		)
	fi

	# Verify subject and test functions are defined in the same order
	while IFS= read -r diff; do
		# shellcheck disable=SC2076
		if [[ $diff =~ '^ ?function' ]]; then
			pass
		elif [[ $diff =~ '^-function' ]]; then
			fail "'$(echo "$diff" | trim 1)' does not match"
		fi
	done <<< "$functions_compared"
}
