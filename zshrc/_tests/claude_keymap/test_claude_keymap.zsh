# shellcheck disable=SC2030,SC2031 # Tests override CLAUDE_KEYMAP_* config inside each $(...) for isolation; subshell-local is intended
function test__claude_keymap {
	assert "$(
		local show_this_help; show_this_help=$(claude_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ $show_this_help =~ "^  \\$ $CLAUDE_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__claude_keymap_P {
	assert "$(
		local orig_config=$CLAUDE_KEYMAP_CONFIG_DIR
		local orig_scratch=$CLAUDE_KEYMAP_SCRATCH_DIR
		local orig_files=("${CLAUDE_KEYMAP_FILES[@]}")
		local orig_folders=("${CLAUDE_KEYMAP_FOLDERS[@]}")

		CLAUDE_KEYMAP_CONFIG_DIR=/tmp/test__claude_keymap_P/config
		CLAUDE_KEYMAP_SCRATCH_DIR=/tmp/test__claude_keymap_P/scratch
		CLAUDE_KEYMAP_FILES=(test.json)
		CLAUDE_KEYMAP_FOLDERS=(subdir)

		mkdir -p "$CLAUDE_KEYMAP_CONFIG_DIR/subdir"
		echo '{"key":"val"}' > "$CLAUDE_KEYMAP_CONFIG_DIR/test.json"
		echo 'file1' > "$CLAUDE_KEYMAP_CONFIG_DIR/subdir/file.txt"

		claude_keymap_P

		cat "$CLAUDE_KEYMAP_SCRATCH_DIR/test.json"
		cat "$CLAUDE_KEYMAP_SCRATCH_DIR/subdir/file.txt"

		rm -rf /tmp/test__claude_keymap_P
		CLAUDE_KEYMAP_CONFIG_DIR=$orig_config
		CLAUDE_KEYMAP_SCRATCH_DIR=$orig_scratch
		CLAUDE_KEYMAP_FILES=("${orig_files[@]}")
		CLAUDE_KEYMAP_FOLDERS=("${orig_folders[@]}")
	)" "$(
		cat <<-eof
			Pushing Claude config to 'scratch' repository...
			Push operation completed.
			{"key":"val"}
			file1
		eof
	)"
}

function test__claude_keymap_PP {
	assert "$(
		local orig_config=$CLAUDE_KEYMAP_CONFIG_DIR
		local orig_scratch=$CLAUDE_KEYMAP_SCRATCH_DIR
		local orig_files=("${CLAUDE_KEYMAP_FILES[@]}")
		local orig_folders=("${CLAUDE_KEYMAP_FOLDERS[@]}")

		CLAUDE_KEYMAP_CONFIG_DIR=/tmp/test__claude_keymap_PP/config
		CLAUDE_KEYMAP_SCRATCH_DIR=/tmp/test__claude_keymap_PP/scratch
		CLAUDE_KEYMAP_FILES=(test.json)
		CLAUDE_KEYMAP_FOLDERS=(subdir)

		mkdir -p "$CLAUDE_KEYMAP_CONFIG_DIR"
		mkdir -p "$CLAUDE_KEYMAP_SCRATCH_DIR/subdir"
		echo '{"pulled":"yes"}' > "$CLAUDE_KEYMAP_SCRATCH_DIR/test.json"
		echo 'pulled_file' > "$CLAUDE_KEYMAP_SCRATCH_DIR/subdir/file.txt"

		claude_keymap_PP

		cat "$CLAUDE_KEYMAP_CONFIG_DIR/test.json"
		cat "$CLAUDE_KEYMAP_CONFIG_DIR/subdir/file.txt"

		rm -rf /tmp/test__claude_keymap_PP
		CLAUDE_KEYMAP_CONFIG_DIR=$orig_config
		CLAUDE_KEYMAP_SCRATCH_DIR=$orig_scratch
		CLAUDE_KEYMAP_FILES=("${orig_files[@]}")
		CLAUDE_KEYMAP_FOLDERS=("${orig_folders[@]}")
	)" "$(
		cat <<-eof
			Pulling Claude config from 'scratch' repository...
			Pull operation completed successfully.
			{"pulled":"yes"}
			pulled_file
		eof
	)"
}
