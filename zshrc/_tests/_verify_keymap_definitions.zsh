function verify_keymap_definitions_section {
	local section_number=$1

	echo
	echo
	echo "$section_number: Verify all keymap entries have corresponding key mapping functions"

	init

	for keymap_file in $(keymap_files); do
		verify_keymap_definitions "$keymap_file"
	done

	print_summary 'keymap entries have corresponding key mapping functions'
}

function verify_keymap_definitions {
	local keymap_file=$1

	namespace=$(pgrep --only-matching "(?<=_NAMESPACE=')\w+(?=')" "$keymap_file" | bw)

	# Find all keymap keys
	local keymap_keys; keymap_keys=$(
		# Ignore comment lines
		grep --invert-match '^#' "$keymap_file" |
			# Extract keymap keys
			pgrep --only-matching "(?<=_DOT})(\w|-)+(?=\s)" | bw | sort --unique
	)

	# Generate all expected mapping functions
	local expected_functions; expected_functions=$(
		# shellcheck disable=SC2001 # We are editing a multiline string
		[[ -n $keymap_keys ]] && echo "$keymap_keys" | sed "s/^/function ${namespace}_/"
	)

	# Find all actual mapping functions
	local actual_functions; actual_functions=$(
		pgrep --only-matching "^function (\w|-)+(?= {)" "$keymap_file" | bw | sort --unique
	)

	# Compare keys and mapping functions; note that `diff` returns nothing if the files are identical
	local functions_compared
	if [[ $expected_functions == "$actual_functions" ]]; then
		functions_compared="$expected_functions"
	else
		functions_compared=$(
			diff -U999999 <(echo "$expected_functions") <(echo "$actual_functions") | bw
		)
	fi

	# Verify subject and test functions are defined in the same order
	while IFS= read -r diff; do
		# shellcheck disable=SC2076
		if [[ $diff =~ '^ ?function' || $diff == "+function $namespace" ]]; then
			pass
		elif [[ $diff =~ '^[-+]function' ]]; then
			fail "'$(echo "$diff" | trim 1)' does not match"
		fi
	done <<< "$functions_compared"
}
