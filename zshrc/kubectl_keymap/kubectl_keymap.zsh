KUBECTL_NAMESPACE='kubectl_keymap'
KUBECTL_ALIAS='k'
KUBECTL_DOT="${KUBECTL_ALIAS}${KEYMAP_DOT}"

KUBECTL_KEYMAP=(
	"${KUBECTL_ALIAS} {kubectl command}"
	''
	"${KUBECTL_DOT}n {namespace}? # Set namespace (to '$GITHUB_DEFAULT_ORG')"
	"${KUBECTL_DOT}e1 {namespace}? # Set namespace, region, and kube config"
	"${KUBECTL_DOT}e2 {namespace}? # Set namespace, region, and kube config"
	"${KUBECTL_DOT}w2 {namespace}? # Set namespace, region, and kube config"
	''
	"${KUBECTL_DOT}k {type} {match}* {-mismatch}* # Get resources as args"
	"${KUBECTL_DOT}g {type} {name} # Get resources"
	"${KUBECTL_DOT}gg {type} {name} # Get resources with \`-o wide\`"
	"${KUBECTL_DOT}d {type} {name} # Describe resources"
	"${KUBECTL_DOT}m {type} {name} # Edit with TextMate"
	''
	"${KUBECTL_DOT}l {pod} # Show logs"
	"${KUBECTL_DOT}ll {pod} # Tail logs"
	"${KUBECTL_DOT}lp {pod} # Show previous logs"
	"${KUBECTL_DOT}b {pod} # Exec into bash"
	"${KUBECTL_DOT}c {command} {pod} # Exec a command"
	"${KUBECTL_DOT}z # Copy history bindings and \`kubectl\` helpers"
	''
	"${KUBECTL_DOT}s {count} {deployment} # Scale a deployment"
	"${KUBECTL_DOT}ss {type} {name} # Restart a deployment/stateful set/daemon set"
	''
	"${KUBECTL_DOT}j {type} {name} # Get resource as json & save a copy"
	"${KUBECTL_DOT}jj # Get the copy of json"
	"${KUBECTL_DOT}y {type} {name} # Get resource as yaml & save a copy"
	"${KUBECTL_DOT}yy # Get the copy of yaml"
	''
	"${KUBECTL_DOT}r # List resource types"
	"${KUBECTL_DOT}r {match}* {-mismatch}* # Filter resource types"
	"${KUBECTL_DOT}rr # Save a copy of resource types"
	"${KUBECTL_DOT}x {type} # Explain a resource type"
	''
	"${KUBECTL_DOT}t {yaml file} # Render Helm template locally"
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

	keymap_show $KUBECTL_NAMESPACE $KUBECTL_ALIAS ${#KUBECTL_KEYMAP} "${KUBECTL_KEYMAP[@]}" "$@"
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
	local params=("$@")

	kubectl describe "${params[@]}"
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
	local params=("$@")

	kubectl get "${params[@]}"
}

function kubectl_keymap_gg {
	local params=("$@")

	kubectl get "${params[@]}" -o wide
}

function kubectl_keymap_j {
	local params=("$@")

	# Save a copy in case original params is not deterministic b/c it references an arg number
	[[ -n ${params[*]} ]] && kubectl get "${params[@]}" -o json | tee ~/Documents/k8.get.json | jq
}

function kubectl_keymap_jj {
	cat ~/Documents/k8.get.json
}

function kubectl_keymap_k {
	[[ -z $1 ]] && return

	local resource_type="$1"; shift
	local filters=("$@")

	kubectl get "$resource_type" | args_keymap_so "${filters[@]}"
}

function kubectl_keymap_l {
	local pod="$1"

	kubectl logs "$pod"
}

function kubectl_keymap_ll {
	local pod="$1"

	kubectl logs -f "$pod"
}

function kubectl_keymap_lp {
	local pod="$1"

	kubectl logs -p "$pod"
}

function kubectl_keymap_m {
	local params=("$@")

	kubectl edit "${params[@]}"
}

function kubectl_keymap_n {
	local namespace=${1:-$GITHUB_DEFAULT_ORG}

	kubectl config set-context --current --namespace "$namespace"
}

function kubectl_keymap_r {
	local filters=("$@")

	args_keymap_s "${filters[@]}" < ~/Documents/k8.api-resources.txt
}

function kubectl_keymap_rr {
	# Save a copy for offline lookup
	kubectl api-resources > ~/Documents/k8.api-resources.txt
}

function kubectl_keymap_s {
	local replica_count="$1"
	local deployment_name="$2"

	kubectl scale --replicas="$replica_count" deploy "$deployment_name"
}

function kubectl_keymap_ss {
	local resource_type="$1"
	local resource_name="$2"

	kubectl rollout restart "$resource_type" "$resource_name"
}

function kubectl_keymap_t {
	local yaml_file="$1"

	helm template --file "$yaml_file" .
}

function kubectl_keymap_w2 {
	# To be overwritten by `ZSHRC_SECRETS`
	return
}

function kubectl_keymap_x {
	local resource_type="$1"

	kubectl explain "$resource_type"
}

function kubectl_keymap_y {
	local params=("$@")

	# Save a copy in case original params is not deterministic b/c it references an arg number
	[[ -n ${params[*]} ]] && kubectl get "${params[@]}" -o yaml | tee ~/Documents/k8.get.yaml | cat
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
