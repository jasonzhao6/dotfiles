# shellcheck disable=SC2030,SC2031 # Tests override KIRO_KEYMAP_* config inside each $(...) for isolation; subshell-local is intended
function test__kiro_keymap {
	assert "$(
		local show_this_help; show_this_help=$(kiro_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $KIRO_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__kiro_keymap_p {
	assert "$(
		local orig_config=$KIRO_KEYMAP_CONFIG_DIR
		local orig_scratch=$KIRO_KEYMAP_SCRATCH_DIR
		local orig_dirs=("${KIRO_KEYMAP_SUB_DIRS[@]}")

		KIRO_KEYMAP_CONFIG_DIR=/tmp/test__kiro_keymap_p/config
		KIRO_KEYMAP_SCRATCH_DIR=/tmp/test__kiro_keymap_p/scratch
		KIRO_KEYMAP_SUB_DIRS=(agents)

		mkdir -p "$KIRO_KEYMAP_CONFIG_DIR/agents"
		echo 'agent1' > "$KIRO_KEYMAP_CONFIG_DIR/agents/a1.txt"

		kiro_keymap_p

		cat "$KIRO_KEYMAP_SCRATCH_DIR/agents/a1.txt"

		rm -rf /tmp/test__kiro_keymap_p
		KIRO_KEYMAP_CONFIG_DIR=$orig_config
		KIRO_KEYMAP_SCRATCH_DIR=$orig_scratch
		KIRO_KEYMAP_SUB_DIRS=("${orig_dirs[@]}")
	)" "$(
		cat <<-eof
			Pushing 'kiro' folder to 'scratch' repository...
			Push operation completed.
			agent1
		eof
	)"
}

function test__kiro_keymap_P {
	assert "$(
		local orig_config=$KIRO_KEYMAP_CONFIG_DIR
		local orig_scratch=$KIRO_KEYMAP_SCRATCH_DIR
		local orig_dirs=("${KIRO_KEYMAP_SUB_DIRS[@]}")

		KIRO_KEYMAP_CONFIG_DIR=/tmp/test__kiro_keymap_P/config
		KIRO_KEYMAP_SCRATCH_DIR=/tmp/test__kiro_keymap_P/scratch
		KIRO_KEYMAP_SUB_DIRS=(agents)

		mkdir -p "$KIRO_KEYMAP_CONFIG_DIR"
		mkdir -p "$KIRO_KEYMAP_SCRATCH_DIR/agents"
		echo 'pulled_agent' > "$KIRO_KEYMAP_SCRATCH_DIR/agents/a1.txt"

		kiro_keymap_P

		cat "$KIRO_KEYMAP_CONFIG_DIR/agents/a1.txt"

		rm -rf /tmp/test__kiro_keymap_P
		KIRO_KEYMAP_CONFIG_DIR=$orig_config
		KIRO_KEYMAP_SCRATCH_DIR=$orig_scratch
		KIRO_KEYMAP_SUB_DIRS=("${orig_dirs[@]}")
	)" "$(
		cat <<-eof
			Pulling 'kiro' folder from 'scratch' repository...
			Pull operation completed successfully.
			pulled_agent
		eof
	)"
}
