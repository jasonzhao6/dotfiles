function test__zsh_keymap {
	assert "$(
		local show_this_help; show_this_help=$(zsh_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $ZSH_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__zsh_keymap__when_specifying_a_md_file_instead_of_key {
	local md='/tmp/test__zsh_keymap__md_passthrough.md'
	printf '# H1\n' > $md

	# Avoid pasteboard archive side-effect from `other_keymap_k`
	echo 'not terminal output' | pbcopy

	assert "$(
		ZSHRC_UNDER_TESTING=1 zsh_keymap $md | bw | compact
	)" "$(
		cat <<-eof
			"test__zsh_keymap__md_passthrough.md"
			# H1
		eof
	)"

	rm $md
}

function test__zsh_keymap_a {
	assert "$(
		local count; count=$(zsh_keymap_a | wc -l)
		local min_count; min_count=$(grep --count '^\talias ' "$ZSHRC_SRC_DIR"/colors.zsh)

		[[ $count -ge $min_count ]] && echo 1
	)" '1'
}

function test__zsh_keymap_a__when_counting_greps {
	assert "$(
		local count; count=$(zsh_keymap_a grep | wc -l)
		local actual_count; actual_count=$(grep --count '^\talias.*grep' "$ZSHRC_SRC_DIR"/colors.zsh)

		[[ $count -eq actual_count ]] && echo 1
	)" '1'
}

function test__zsh_keymap_f {
	assert "$(
		[[ $(zsh_keymap_f | wc -l) -gt 400 ]] && echo 1
	)" '1'
}

function test__zsh_keymap_f__when_counting_0_ending_functions {
	assert "$(
		local count; count=$(zsh_keymap_f '0$' | wc -l)

		# `3`: `10, 20, 0` from `args_numbers.zsh`
		[[ $count -ge 3 ]] && echo 1
	)" '1'
}

function test__zsh_keymap_h {
	local history_entries; history_entries=$(
		cat <<-eof
			: 1735711246:0;echo 5
			: 1735711248:0;echo 1
			: 1735711249:0;echo 3
			: 1735711249:0;echo 3
			: 1735711250:0;echo 3
			: 1735711251:0;echo 4
			: 1735711252:0;echo 2
		eof
	)

	# shellcheck disable=SC2030
	assert "$(
		local histfile=$HISTFILE
		HISTFILE='/tmp/test__zsh_keymap_h'
		echo "$history_entries" > $HISTFILE

		zh

		rm $HISTFILE
		HISTFILE=$histfile
	)" "$(
		cat <<-eof
		     1	echo 1
		     2	echo 2
		     3	echo 3
		     4	echo 4
		     5	echo 5
		eof
	)"
}

function test__zsh_keymap_h__when_filtering {
	local history_entries; history_entries=$(
		cat <<-eof
			: 1735711246:0;echo 5
			: 1735711248:0;echo 1
			: 1735711249:0;echo 3
			: 1735711249:0;echo 3
			: 1735711250:0;echo 3
			: 1735711251:0;echo 4
			: 1735711252:0;echo 2
		eof
	)

	# shellcheck disable=SC2030
	assert "$(
		local histfile=$HISTFILE
		HISTFILE='/tmp/test__zsh_keymap_h__when_filtering'
		echo "$history_entries" > $HISTFILE

		zh 3

		rm $HISTFILE
		HISTFILE=$histfile
	)" "$(
		cat <<-eof
		     1	echo $(grep_color 3)
		eof
	)"
}

function test__zsh_keymap_hc {
	# shellcheck disable=SC2031
	assert "$(
		local histfile=$HISTFILE
		HISTFILE='/tmp/test__h'
		touch $HISTFILE

		zhc
		[[ -e $HISTFILE ]] && echo present || echo absent

		HISTFILE=$histfile
	)" 'absent'
}

function test__zsh_keymap_s__when_args_history_is_not_initialized {
	args_history_init
	local args_history_max=$ARGS_HISTORY_MAX

	assert "$(
		ARGS_HISTORY_MAX=
		ZSHRC_UNDER_TESTING=1 zsh_keymap_s
		echo "$ARGS_HISTORY_MAX"
	)" "$args_history_max"

	args_history_reset
}

function test__zsh_keymap_s__when_args_history_is_already_initialized {
	local overwrite='<overwrite>'

	assert "$(
		ARGS_HISTORY_MAX=$overwrite
		ZSHRC_UNDER_TESTING=1 zsh_keymap_s
		echo $ARGS_HISTORY_MAX
	)" "$overwrite"

	args_history_reset
}

function test__zsh_keymap_v__replaces_heading_dashes_with_hashes {
	local md='/tmp/test__zsh_keymap_v.md'
	printf '# H1\n\n## H2\n' > $md

	assert "$(zsh_keymap_v $md | bw | compact)" "$(
		cat <<-eof
			# H1
			## H2
		eof
	)"

	rm $md
}

function test__zsh_keymap_v__swaps_heading_blue_for_cyan {
	local md='/tmp/test__zsh_keymap_v.md'
	echo '# H1' > $md

	# shellcheck disable=SC2076
	assert "$(
		local output; output=$(zsh_keymap_v $md)
		[[ $output =~ $'\e\\[36m' ]] && [[ ! $output =~ $'\e\\[34m' ]] && echo 1
	)" '1'

	rm $md
}

function test__zsh_keymap_v__replaces_fence_dashes_with_backticks {
	local md='/tmp/test__zsh_keymap_v.md'
	printf '```\ncode\n```\n' > $md

	assert "$(zsh_keymap_v $md | bw | compact)" "$(
		cat <<-eof
			\`\`\`
			code
			\`\`\`
		eof
	)"

	rm $md
}

function test__zsh_keymap_v__swaps_fence_green_for_yellow {
	local md='/tmp/test__zsh_keymap_v.md'
	printf '```\ncode\n```\n' > $md

	# shellcheck disable=SC2076
	assert "$(
		local output; output=$(zsh_keymap_v $md)
		[[ $output =~ $'\e\\[33m```' ]] && [[ ! $output =~ $'\e\\[32m' ]] && echo 1
	)" '1'

	rm $md
}

function test__zsh_keymap_w {
	assert "$(zsh_keymap_w)" "$(
		cat <<-eof
			$(red_bar 'Required: <name>')
		eof
	)"
}

function test__zsh_keymap_w__when_program_is_not_found {
	assert "$(
		zsh_keymap_w does_not_exist
	)" "$(
		cat <<-eof
			$(red_bar '`does_not_exist` not found')
		eof
	)"
}

function test__zsh_keymap_w__when_program_is_an_alias {
	assert "$(
		zsh_keymap_w z0 | bw
	)" "$(
		cat <<-eof

			  # \`z0\` is aliased to \`zsh_keymap_0\`

			  $ z.0 # Session history in memory & file

		     1	zsh_keymap_0 () {
		     2		unset -f zshaddhistory
		     3	}
		eof
	)"
}

function test__zsh_keymap_w__when_input_is_a_function {
	assert "$(
		zsh_keymap_w zsh_keymap_0
	)" "$(
		cat <<-eof

		     1	zsh_keymap_0 () {
		     2		unset -f zshaddhistory
		     3	}
		eof
	)"
}

function test__zsh_keymap_z__renders_pasteboard_file {
	local md='/tmp/test__zsh_keymap_z.md'
	printf '# H1\n' > $md

	# Avoid pasteboard archive side-effect from `other_keymap_k`
	echo 'not terminal output' | pbcopy

	assert "$(
		echo "$md" | pbcopy
		ZSHRC_UNDER_TESTING=1 zsh_keymap_z | bw | compact
	)" "$(
		cat <<-eof
			"test__zsh_keymap_z.md"
			# H1
		eof
	)"

	rm $md
}

function test__zsh_keymap_z__when_pasteboard_is_not_a_file {
	assert "$(
		ZSH_KEYMAP_Z_LAST_FILE=
		echo 'not a file' | pbcopy
		zsh_keymap_z
	)" "$(
		cat <<-eof
			$(red_bar 'Invalid file path in pasteboard')
		eof
	)"
}

function test__zsh_keymap_z__when_pasteboard_is_not_a_file_but_last_file_exists {
	local md='/tmp/test__zsh_keymap_z__fallback.md'
	printf '# Fallback\n' > $md

	# Avoid pasteboard archive side-effect from `other_keymap_k`
	echo 'not terminal output' | pbcopy

	assert "$(
		ZSH_KEYMAP_Z_LAST_FILE=$md
		echo 'not a file' | pbcopy
		ZSHRC_UNDER_TESTING=1 zsh_keymap_z | bw | compact
	)" "$(
		cat <<-eof
			"test__zsh_keymap_z__fallback.md"
			# Fallback
		eof
	)"

	rm $md
}
