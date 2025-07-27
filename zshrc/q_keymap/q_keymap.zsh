Q_NAMESPACE='q_keymap'
Q_ALIAS='q'
Q_DOT="${Q_ALIAS}${KEYMAP_DOT}"

Q_KEYMAP=(
	"${Q_DOT}q # Chat without MCP"
	"${Q_DOT}h # Chat with GitHub MCP, and \`pbcopy\` trust instructions"
	"${Q_DOT}j # Chat with Jira MCP, and \`pbcopy\` trust instructions"
	''
	"${Q_DOT}0 {command}? # Invoke \`q\`"
	"${Q_DOT}4 {command}? # Invoke \`q chat\` with \`claude-4-sonnet\`"
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
	# Create pasteboard instruction to trust read-only tools
	local github_readonly_tools=$(
		grep --color=never --only-matching 'mcp_github___[a-zA-Z_]*' \
			"$ZSHRC_DIR/${Q_NAMESPACE}/mcp_tools.github.txt" |
			egrep --color=never '(_get_|_list_|_search_|_download_)'
	)
	local pasteboard_content="/tools trust"$'\n'"$github_readonly_tools"
	echo "$pasteboard_content" | pbcopy

	cp "$Q_KEYMAP_DIR"/profiles/github/mcp.json "$Q_KEYMAP_DIR"/
	q_keymap_4 --profile github
}

function q_keymap_j {
	# Create pasteboard instruction to trust read-only tools
	local jira_readonly_tools=$(
		grep --color=never --only-matching 'mcp_atlassian___jira_[a-zA-Z_]*' \
			"$ZSHRC_DIR/${Q_NAMESPACE}/mcp_tools.jira.txt" |
			egrep --color=never '(_get_|_search_|_download_)'
	)
	local pasteboard_content="/tools trust"$'\n'"$jira_readonly_tools"
	echo "$pasteboard_content" | pbcopy

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
