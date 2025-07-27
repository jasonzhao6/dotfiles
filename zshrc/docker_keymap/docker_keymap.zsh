DOCKER_NAMESPACE='docker_keymap'
DOCKER_ALIAS='d'
DOCKER_DOT="${DOCKER_ALIAS}${KEYMAP_DOT}"

DOCKER_KEYMAP=(
	"${DOCKER_ALIAS} <docker command>"
	''
	"${DOCKER_DOT}s # Login with AWS credentials"
)

keymap_init $DOCKER_NAMESPACE $DOCKER_ALIAS "${DOCKER_KEYMAP[@]}"

source "$ZSHRC_DIR/$DOCKER_NAMESPACE/docker_commands.zsh"

function docker_keymap {
	# If the first arg is a `docker` command, pass it through
	for command in "${DOCKER_COMMANDS[@]}"; do
		if [[ $command == "$1" ]]; then
			docker "$@"
			return
		fi
	done

	keymap_show $DOCKER_NAMESPACE $DOCKER_ALIAS ${#DOCKER_KEYMAP} "${DOCKER_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function docker_keymap_s {
	aws ecr get-login-password --region us-east-1 |
		docker login --username AWS --password-stdin "$DOCKER_ECR_URL"
}
