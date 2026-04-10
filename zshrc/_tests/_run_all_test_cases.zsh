function run_all_test_cases_section {
	local section_number=$1

	if [[ -z $ZSHRC_TESTS_NAME_FILTER ]]; then
		printf "\n%s: Run all test cases in parallel\n" "$section_number"
	else
		printf "\n%s: Run test cases matching \`*%s*\`\n" "$section_number" "$ZSHRC_TESTS_NAME_FILTER"
	fi

	pasteboard=$(pbpaste) # Save pasteboard value since some tests overwrite it

	local tmpdir=$(mktemp -d)
	local pids=()
	local files=()

	#	Parallelize test executions by file
	for test in $(find_test_files); do
		local base=$(basename "$test")
		files+=("$base")

		(
			# Isolate pasteboard per subshell via file-backed overrides
			function pbcopy { cat > "$tmpdir/$base.pb"; }
			function pbpaste { cat "$tmpdir/$base.pb" 2>/dev/null; }

			init
			source "$test"
			execute_tests

			# Serialize results
			echo "$passes $total" > "$tmpdir/$base.result"
			[[ -n $failed ]] && printf '%b' "$failed" > "$tmpdir/$base.failed"
			[[ -n $debug ]] && printf '%b' "$debug" > "$tmpdir/$base.debug"
		) > "$tmpdir/$base.dots" 2>/dev/null &
		pids+=($!)
	done

	# Wait for each subshell and aggregate its results as it completes
	passes=0
	total=0
	failed=''
	debug=''

	local p t
	for ((i = 1; i <= ${#files[@]}; i++)); do
		wait ${pids[$i]}
		local base=${files[$i]}

		# Print buffered dots for this file
		[[ -s "$tmpdir/$base.dots" ]] && cat "$tmpdir/$base.dots"

		# Accumulate pass/total counts
		read p t < "$tmpdir/$base.result"
		((passes += p))
		((total += t))

		# Collect failure and debug output
		[[ -f "$tmpdir/$base.failed" ]] && failed+=$(cat "$tmpdir/$base.failed")
		[[ -f "$tmpdir/$base.debug" ]] && debug+=$(cat "$tmpdir/$base.debug")
	done

	print_summary 'tests passed'

	echo "$pasteboard" | pbcopy # Restore saved pasteboard value
	rm -rf "$tmpdir"
}
