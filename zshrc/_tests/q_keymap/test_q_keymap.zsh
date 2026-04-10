function test__q_keymap {
	assert "$(
		local show_this_help; show_this_help=$(q_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $Q_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__q_keymap_p {
	assert "$(
		local orig_config=$Q_KEYMAP_CONFIG_DIR
		local orig_scratch=$Q_KEYMAP_SCRATCH_DIR
		local orig_dirs=("${Q_KEYMAP_SUB_DIRS[@]}")

		Q_KEYMAP_CONFIG_DIR=/tmp/test__q_keymap_p/config
		Q_KEYMAP_SCRATCH_DIR=/tmp/test__q_keymap_p/scratch
		Q_KEYMAP_SUB_DIRS=(agents)

		mkdir -p "$Q_KEYMAP_CONFIG_DIR/agents"
		echo 'agent1' > "$Q_KEYMAP_CONFIG_DIR/agents/a1.txt"

		q_keymap_p

		cat "$Q_KEYMAP_SCRATCH_DIR/agents/a1.txt"

		rm -rf /tmp/test__q_keymap_p
		Q_KEYMAP_CONFIG_DIR=$orig_config
		Q_KEYMAP_SCRATCH_DIR=$orig_scratch
		Q_KEYMAP_SUB_DIRS=("${orig_dirs[@]}")
	)" "$(
		cat <<-eof
			Pushing 'kiro' folder to 'scratch' repository...
			Push operation completed.
			agent1
		eof
	)"
}

function test__q_keymap_P {
	assert "$(
		local orig_config=$Q_KEYMAP_CONFIG_DIR
		local orig_scratch=$Q_KEYMAP_SCRATCH_DIR
		local orig_dirs=("${Q_KEYMAP_SUB_DIRS[@]}")

		Q_KEYMAP_CONFIG_DIR=/tmp/test__q_keymap_P/config
		Q_KEYMAP_SCRATCH_DIR=/tmp/test__q_keymap_P/scratch
		Q_KEYMAP_SUB_DIRS=(agents)

		mkdir -p "$Q_KEYMAP_CONFIG_DIR"
		mkdir -p "$Q_KEYMAP_SCRATCH_DIR/agents"
		echo 'pulled_agent' > "$Q_KEYMAP_SCRATCH_DIR/agents/a1.txt"

		q_keymap_P

		cat "$Q_KEYMAP_CONFIG_DIR/agents/a1.txt"

		rm -rf /tmp/test__q_keymap_P
		Q_KEYMAP_CONFIG_DIR=$orig_config
		Q_KEYMAP_SCRATCH_DIR=$orig_scratch
		Q_KEYMAP_SUB_DIRS=("${orig_dirs[@]}")
	)" "$(
		cat <<-eof
			Pulling 'kiro' folder from 'scratch' repository...
			Pull operation completed successfully.
			pulled_agent
		eof
	)"
}
