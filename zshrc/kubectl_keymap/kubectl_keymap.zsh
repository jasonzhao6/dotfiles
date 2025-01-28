KUBECTL_NAMESPACE='kubectl_keymap'
KUBECTL_ALIAS='k'
KUBECTL_DOT="${KUBECTL_ALIAS}${KEYMAP_DOT}"

KUBECTL_KEYMAP=(
	"${KUBECTL_ALIAS} {kubectl command}"
	''
	"${KUBECTL_DOT}s # Save a copy of resource types"
	"${KUBECTL_DOT}r # List resource types"
	"${KUBECTL_DOT}r {match}* {-mismatch}* # Filter resource types"
	"${KUBECTL_DOT}x {resource type} # Explain a resource type"
	"${KUBECTL_DOT}h {yaml file} # Render Helm template locally"
	''
	"${KUBECTL_DOT}n {name} # Set namespace"
	"${KUBECTL_DOT}e1 # Set namespace and use us-east-1 region"
	"${KUBECTL_DOT}e2 # Set namespace and use us-east-2 region"
	"${KUBECTL_DOT}w2 # Set namespace and and us-west-2 region"
	''
	"${KUBECTL_DOT}e {command} # Exec a command"
	"${KUBECTL_DOT}g {resource type} # Get resources"
	"${KUBECTL_DOT}k {resource type} # Get resources as args"
	"${KUBECTL_DOT}d {command} # Describe resource(s)"
	''
	"${KUBECTL_DOT}b {pod} # Exec into bash"
	"${KUBECTL_DOT}c {pod} # Exec a command"
	"${KUBECTL_DOT}l {pod} # Show logs"
	''
	"${KUBECTL_DOT}j {command} # Get resource as json & save a copy"
	"${KUBECTL_DOT}jj {command} # Get the copy of json"
	"${KUBECTL_DOT}y {command} # Get resource as yaml & save a copy"
	"${KUBECTL_DOT}yy {command} # Get the copy of yaml"
	''
	"${KUBECTL_DOT}z # Copy history bindings and \`kubectl\` helpers"
)

keymap_init $KUBECTL_NAMESPACE $KUBECTL_ALIAS "${KUBECTL_KEYMAP[@]}"

source "$ZSHRC_DIR/$KUBECTL_NAMESPACE/kubectl_commands.zsh"

function kubectl_keymap {
	# If the first arg is a `kubectl` command, pass it through
	for command in "${KUBECTL_COMMANDS[@]}"; do
		if [[ $command == "$1" ]]; then
			kubectl "$@"
			return
		fi
	done

	keymap_invoke $KUBECTL_NAMESPACE $KUBECTL_ALIAS ${#KUBECTL_KEYMAP} "${KUBECTL_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function kubectl_keymap_b {
	local pod="$1"

	kubectl exec -it "$pod" -- bash
}

function kubectl_keymap_c {
	local command=("${@[1,-2]}")
	local pod="${*[-1]}"

	kubectl exec "$pod" -- "${command[@]}"
}

function kubectl_keymap_d {
	local command=("$@")

	kubectl describe "${command[@]}"
}

function kubectl_keymap_e {
	local command=("$@")

	kubectl exec "${command[@]}"
}

function kubectl_keymap_e1 {
	# To be overwritten by `ZSHRC_SECRETS`
	return
}

function kubectl_keymap_e2 {
	# To be overwritten by `ZSHRC_SECRETS`
	return
}

function kubectl_keymap_g {
	local resource="$1"

	kubectl get "$resource"
}

function kubectl_keymap_h {
	local yaml_file="$1"

	helm template -f "$yaml_file" .
}

function kubectl_keymap_j {
	local command=("$@")

	# Save a copy in case original command is not deterministic b/c it references an arg number
	[[ -n ${command[*]} ]] && kubectl get "${command[@]}" -o json | tee ~/Documents/k8.get.json | jq
}

function kubectl_keymap_jj {
	cat ~/Documents/k8.get.json
}

function kubectl_keymap_k {
	local resource="$1"; shift
	local filters=("$@")

	kubectl get "$resource" | args_keymap_so "${filters[@]}"
}

function kubectl_keymap_l {
	local pod="$1"

	kubectl logs "$pod"
}

function kubectl_keymap_n {
	local namespace=$1

	kubectl config set-context --current --namespace "$namespace"
}

function kubectl_keymap_r {
	local filters=("$@")

	args_keymap_s "${filters[@]}" < ~/Documents/k8.api-resources.txt
}

function kubectl_keymap_s {
	# Save a copy for offline lookup
	kubectl api-resources > ~/Documents/k8.api-resources.txt
}

function kubectl_keymap_w2 {
	# To be overwritten by `ZSHRC_SECRETS`
	return
}

function kubectl_keymap_x {
	local resource="$1"

	kubectl explain "$resource"
}

function kubectl_keymap_y {
	local command=("$@")

	# Save a copy in case original command is not deterministic b/c it references an arg number
	[[ -n ${command[*]} ]] && kubectl get "${command[@]}" -o yaml | tee ~/Documents/k8.get.yaml | cat
}

function kubectl_keymap_yy {
	cat ~/Documents/k8.get.yaml
}

AWS_CLI_CACHE_DIR="$HOME/.aws/cli/cache"
AWS_CLI_CACHE_JQ=$(
	cat <<-eof | tr -d '\n'
		.Credentials | [
			"export AWS_ACCESS_KEY_ID='\(.AccessKeyId)'",
			"export AWS_SECRET_ACCESS_KEY='\(.SecretAccessKey)'",
			"export AWS_SESSION_TOKEN='\(.SessionToken)'"
		]
	eof
)

function kubectl_keymap_z {
	# `AWS_CLI_CACHE_DIR` contains cached creds for multiple roles
	# To get only the current role, empty the cache and run a command
	rm -rf "$AWS_CLI_CACHE_DIR"
	aws sts get-caller-identity
	local current_role; current_role=$(ls "$AWS_CLI_CACHE_DIR")

	cat <<-eof | pbcopy
		bind '"\e[A": history-search-backward'
		bind '"\e[B": history-search-forward'

		alias k='kubectl'
		alias kg='kubectl get'
		alias kd='kubectl describe'

		$(jq "$AWS_CLI_CACHE_JQ" "$AWS_CLI_CACHE_DIR/$current_role" | trim_list)

		aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name $KUBECTL_DEFAULT_CLUSTER
		kubectl config set-context --current --namespace=$GITHUB_DEFAULT_ORG
	eof

	echo
	green_bar 'History bindings and `kubectl` helpers copied to pasteboard'
}
