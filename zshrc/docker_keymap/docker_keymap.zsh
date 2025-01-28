DOCKER_NAMESPACE='docker_keymap'
DOCKER_ALIAS='d'
DOCKER_DOT="${DOCKER_ALIAS}${KEYMAP_DOT}"

DOCKER_KEYMAP=(
	"${DOCKER_DOT}, # Login with AWS credentials"
)

keymap_init $DOCKER_NAMESPACE $DOCKER_ALIAS "${DOCKER_KEYMAP[@]}"

source "$ZSHRC_DIR/$DOCKER_NAMESPACE/docker_commands.zsh"

function docker_keymap {
	# If the first arg is a `docker` command, pass it through
	for command in "${DOCKER_COMMANDS[@]}"; do
		if [[ $command == $1 ]]; then
			docker "$@"
			return
		fi
	done

	keymap_invoke $DOCKER_NAMESPACE $DOCKER_ALIAS ${#DOCKER_KEYMAP} "${DOCKER_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

# shellcheck disable=SC1064,SC1072,SC1073 # Allow `,` in function name
function docker_keymap_, {
	aws ecr get-login-password --region us-east-1 |
		docker login --username AWS --password-stdin $DOCKER_ECR_URL
}
