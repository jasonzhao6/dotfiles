function claude_helpers_check_docker {
	# Check if Docker is running; Claude's MCP servers run on it
	docker info 2> /dev/null |
		grep 'Server Version' > /dev/null &&
		green_bar 'Docker is running' ||
		red_bar 'Docker is not running'
		echo
}
