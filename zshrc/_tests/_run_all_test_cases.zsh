function run_all_test_cases_section {
	local section_number=$1

	if [[ -z $ZSHRC_TESTS_NAME_FILTER ]]; then
		printf "\n%s: Run keymap test files in parallel\n" "$section_number"
	else
		printf "\n%s: Run keymap tests matching \`*%s*\`\n" "$section_number" "$ZSHRC_TESTS_NAME_FILTER"
	fi

	pasteboard=$(pbpaste) # Save pasteboard value since some tests overwrite it

	local tmpdir=$(mktemp -d)
	local pids=()
	local files=()

	# Save stdout for streaming dots from subshells
	exec 3>&1

	#	Parallelize test executions by file
	for test in $(find_test_files); do
		local base=$(basename "$test")
		files+=("$base")

		(
			# Isolate shared resources per subshell
			function pbcopy { cat > "$tmpdir/$base.pb"; }
			function pbpaste { cat "$tmpdir/$base.pb" 2>/dev/null; }
			ARGS_YANK_FILE="$tmpdir/$base.yank"
			ARGS_BACKGROUND_OUTPUTS_FILE="$tmpdir/$base.bg"

			# Override `pass`/`fail` from `_test_harness.zsh` to stream dots via fd 3,
			# bypassing the subshell's `/dev/null` redirect on stdout
			function pass { ((passes++)); ((total++)); echo -n . >&3; }
			function fail {
				local name=$1; local output=$2; local expected=$3
				failed+="\n$(red_bg fail): $name"
				((total++))
				echo -n f >&3
				if [[ -n $output || -n $expected ]]; then
					debug+="\n\n$(red_bg debug): $name\n"
					debug+=$(diff -u <(echo "$expected") <(echo "$output") | sed '/--- /d; /+++ /d; /@@ /d')
				fi
			}

			init
			source "$test"
			for func in $(typeset +f | command grep '^test__'); do
				enqueue_test "$func"
			done
			run_tests

			# Serialize results
			echo "$passes $total" > "$tmpdir/$base.result"
			[[ -n $failed ]] && printf '%b' "$failed" > "$tmpdir/$base.failed"
			[[ -n $debug ]] && printf '%b' "$debug" > "$tmpdir/$base.debug"
		) > /dev/null 2>/dev/null &
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

		# Accumulate pass/total counts
		read p t < "$tmpdir/$base.result"
		((passes += p))
		((total += t))

		# Collect failure and debug output
		[[ -f "$tmpdir/$base.failed" ]] && failed+=$(cat "$tmpdir/$base.failed")
		[[ -f "$tmpdir/$base.debug" ]] && debug+=$(cat "$tmpdir/$base.debug")
	done

	exec 3>&-

	print_summary 'keymap tests passed'

	echo "$pasteboard" | pbcopy # Restore saved pasteboard value
	rm -rf "$tmpdir"
}
