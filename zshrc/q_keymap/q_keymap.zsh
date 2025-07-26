Q_NAMESPACE='q_keymap'
Q_ALIAS='q'
Q_DOT="${Q_ALIAS}${KEYMAP_DOT}"

Q_KEYMAP=(
	"${Q_DOT}q # Invoke \`q chat\` without any MCP"
	"${Q_DOT}h # Invoke \`q chat\` with GitHub MCP"
	"${Q_DOT}j # Invoke \`q chat\` with Jira MCP"
	''
	"${Q_DOT}0 # Invoke the plain \`q\` command"
	"${Q_DOT}4 # Invoke \`q chat\` with \`claude-4-sonnet\`"
	''
	"${Q_DOT}p # Push \`amazonq\` folder to \`scratch\` repo"
	"${Q_DOT}P # Pull \`amazonq\` folder from \`scratch\` repo"
)

keymap_init $Q_NAMESPACE $Q_ALIAS "${Q_KEYMAP[@]}"

function q_keymap {
	keymap_show $Q_NAMESPACE $Q_ALIAS ${#Q_KEYMAP} "${Q_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

Q_KEYMAP_DIR="$HOME/.aws/amazonq"

function q_keymap_0 {
	~/.local/bin/q "$@"
}

function q_keymap_4 {
	q_keymap_0 chat --model claude-4-sonnet "$@"
}

function q_keymap_h {
	cp "$Q_KEYMAP_DIR"/profiles/github/mcp.json "$Q_KEYMAP_DIR"/
	q_keymap_4 --profile github
}

function q_keymap_j {
	cp "$Q_KEYMAP_DIR"/profiles/jira/mcp.json "$Q_KEYMAP_DIR"/
	q_keymap_4 --profile jira
}

function q_keymap_p {
	echo "Pushing amazonq folder to scratch repository..."
	cp -r "$HOME/.aws/amazonq" "$HOME/GitHub/jasonzhao6/scratch/"

	if [ $? -eq 0 ]; then
		echo "Copy completed successfully."

		# Delete mcp.json file in the first level of the copied folder
		if [ -f "$HOME/GitHub/jasonzhao6/scratch/amazonq/mcp.json" ]; then
			rm "$HOME/GitHub/jasonzhao6/scratch/amazonq/mcp.json"
			echo "Deleted mcp.json from copied folder."
		fi

		echo "Push operation completed."
	else
		echo "Error: Failed to copy amazonq folder."
	fi
}

function q_keymap_P {
	echo "Pulling amazonq folder from scratch repository..."

	if [ -d "$HOME/GitHub/jasonzhao6/scratch/amazonq" ]; then
		cp -r "$HOME/GitHub/jasonzhao6/scratch/amazonq" "$HOME/.aws/"

		if [ $? -eq 0 ]; then
			echo "Pull operation completed successfully."
		else
			echo "Error: Failed to copy amazonq folder from scratch repository."
		fi
	else
		echo "Error: amazonq folder not found in scratch repository."
	fi
}

function q_keymap_q {
	rm -f "$Q_KEYMAP_DIR"/mcp.json
	q_keymap_4
}
