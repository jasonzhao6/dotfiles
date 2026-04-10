function test__claude_keymap {
	assert "$(
		local show_this_help; show_this_help=$(claude_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $CLAUDE_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__claude_keymap_u {
	assert "$(
		local orig_config=$CLAUDE_KEYMAP_CONFIG_DIR
		local orig_scratch=$CLAUDE_KEYMAP_SCRATCH_DIR
		local orig_files=("${CLAUDE_KEYMAP_FILES[@]}")
		local orig_folders=("${CLAUDE_KEYMAP_FOLDERS[@]}")

		CLAUDE_KEYMAP_CONFIG_DIR=/tmp/test__claude_keymap_u/config
		CLAUDE_KEYMAP_SCRATCH_DIR=/tmp/test__claude_keymap_u/scratch
		CLAUDE_KEYMAP_FILES=(test.json)
		CLAUDE_KEYMAP_FOLDERS=(skills)

		mkdir -p "$CLAUDE_KEYMAP_CONFIG_DIR/skills"
		echo '{"key":"val"}' > "$CLAUDE_KEYMAP_CONFIG_DIR/test.json"
		echo 'skill1' > "$CLAUDE_KEYMAP_CONFIG_DIR/skills/s1.txt"

		claude_keymap_u

		cat "$CLAUDE_KEYMAP_SCRATCH_DIR/test.json"
		cat "$CLAUDE_KEYMAP_SCRATCH_DIR/skills/s1.txt"

		rm -rf /tmp/test__claude_keymap_u
		CLAUDE_KEYMAP_CONFIG_DIR=$orig_config
		CLAUDE_KEYMAP_SCRATCH_DIR=$orig_scratch
		CLAUDE_KEYMAP_FILES=("${orig_files[@]}")
		CLAUDE_KEYMAP_FOLDERS=("${orig_folders[@]}")
	)" "$(
		cat <<-eof
			Pushing Claude config to 'scratch' repository...
			Push operation completed.
			{"key":"val"}
			skill1
		eof
	)"
}

function test__claude_keymap_U {
	assert "$(
		local orig_config=$CLAUDE_KEYMAP_CONFIG_DIR
		local orig_scratch=$CLAUDE_KEYMAP_SCRATCH_DIR
		local orig_files=("${CLAUDE_KEYMAP_FILES[@]}")
		local orig_folders=("${CLAUDE_KEYMAP_FOLDERS[@]}")

		CLAUDE_KEYMAP_CONFIG_DIR=/tmp/test__claude_keymap_U/config
		CLAUDE_KEYMAP_SCRATCH_DIR=/tmp/test__claude_keymap_U/scratch
		CLAUDE_KEYMAP_FILES=(test.json)
		CLAUDE_KEYMAP_FOLDERS=(skills)

		mkdir -p "$CLAUDE_KEYMAP_CONFIG_DIR"
		mkdir -p "$CLAUDE_KEYMAP_SCRATCH_DIR/skills"
		echo '{"pulled":"yes"}' > "$CLAUDE_KEYMAP_SCRATCH_DIR/test.json"
		echo 'pulled_skill' > "$CLAUDE_KEYMAP_SCRATCH_DIR/skills/s1.txt"

		claude_keymap_U

		cat "$CLAUDE_KEYMAP_CONFIG_DIR/test.json"
		cat "$CLAUDE_KEYMAP_CONFIG_DIR/skills/s1.txt"

		rm -rf /tmp/test__claude_keymap_U
		CLAUDE_KEYMAP_CONFIG_DIR=$orig_config
		CLAUDE_KEYMAP_SCRATCH_DIR=$orig_scratch
		CLAUDE_KEYMAP_FILES=("${orig_files[@]}")
		CLAUDE_KEYMAP_FOLDERS=("${orig_folders[@]}")
	)" "$(
		cat <<-eof
			Pulling Claude config from 'scratch' repository...
			Pull operation completed successfully.
			{"pulled":"yes"}
			pulled_skill
		eof
	)"
}
