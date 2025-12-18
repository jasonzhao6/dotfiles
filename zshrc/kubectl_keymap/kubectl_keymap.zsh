KUBECTL_NAMESPACE='kubectl_keymap'
KUBECTL_ALIAS='k'
KUBECTL_DOT="${KUBECTL_ALIAS}${KEYMAP_DOT}"

KUBECTL_KEYMAP=(
	"${KUBECTL_ALIAS} <kubectl command>"
	''
	"${KUBECTL_DOT}n <namespace>? # Set QA namespace (to '$GITHUB_DEFAULT_ORG')"
	"${KUBECTL_DOT}e1 <namespace>? # Set QA namespace, region, and kube config"
	"${KUBECTL_DOT}e2 <namespace>? # Set QA namespace, region, and kube config"
	"${KUBECTL_DOT}w2 <namespace>? # Set QA namespace, region, and kube config"
	''
	"${KUBECTL_DOT}k <type> <match>* <-mismatch>* # Get resources as args"
	"${KUBECTL_DOT}h <match>* <-mismatch>* # Get pods as args"
	"${KUBECTL_DOT}hh <match>* <-mismatch>* # Get unready pods as args"
	"${KUBECTL_DOT}t <match>* <-mismatch>* # Get deployments as args"
	"${KUBECTL_DOT}m <pod> # Edit a pod with TextMate" #
	"${KUBECTL_DOT}w <deployment> # Edit a deployment with TextMate" #
	"${KUBECTL_DOT}v <type> <name> # Edit a given type with TextMate" #
	''
	"${KUBECTL_DOT}c (e11,e12,e21,w21)? # Copy Prod helpers and history bindings"
	"${KUBECTL_DOT}b <pod> # Exec into bash"
	"${KUBECTL_DOT}bc <command> <pod> # Exec a command"
	"${KUBECTL_DOT}l <pod> # Show logs"
	"${KUBECTL_DOT}ll <pod> # Tail logs"
	"${KUBECTL_DOT}lp <pod> # Show previous logs"
	''
	"${KUBECTL_DOT}r <deployment> # Restart a deployment"
	"${KUBECTL_DOT}rd <daemon set> # Restart a daemon set"
	"${KUBECTL_DOT}rs <stateful set> # Restart a stateful set"
	"${KUBECTL_DOT}rm <pod> # Remove a pod"
	"${KUBECTL_DOT}s <count> <deployment> # Scale a deployment"
	''
	"${KUBECTL_DOT}f <match>* <-mismatch>* # Filter resource types"
	"${KUBECTL_DOT}ff # Save a copy of resource types"
	"${KUBECTL_DOT}g <type> <name> # Get resources"
	"${KUBECTL_DOT}gg <type> <name> # Get resources with \`-o wide\`"
	"${KUBECTL_DOT}d <type> <name> # Describe resources"
	"${KUBECTL_DOT}j <type> <name> # Get resource as json & save a copy"
	"${KUBECTL_DOT}jj # Get the copy of json"
	"${KUBECTL_DOT}y <type> <name> # Get resource as yaml & save a copy"
	"${KUBECTL_DOT}yy # Get the copy of yaml"
	''
	"${KUBECTL_DOT}u # Run unit tests and update snapshots"
	"${KUBECTL_DOT}p <yaml file> # Print spec from yaml file locally"
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

function kubectl_keymap_bc {
	local command=("${@[1,-2]}")
	local pod="${*[-1]}"

	kubectl exec "$pod" -- "${command[@]}"
}

AWS_SSO_CACHE_DIR="$HOME/.aws/britive/cache"
AWS_SSO_CACHE_JQ=$(
	cat <<-eof | tr -d '\n'
		.Credentials | [
			"export AWS_ACCESS_KEY_ID='\(.AccessKeyId)'",
			"export AWS_SECRET_ACCESS_KEY='\(.SecretAccessKey)'",
			"export AWS_SESSION_TOKEN='\(.SessionToken)'"
		]
	eof
)

function kubectl_keymap_c {
	local option=$1
	local kubectl_cluster

	case $AWS_DEFAULT_REGION in
		us-east-1) kubectl_cluster=$KUBECTL_USE11_CLUSTER;;
		us-east-2) kubectl_cluster=$KUBECTL_USE21_CLUSTER;;
		us-west-2) kubectl_cluster=$KUBECTL_USW21_CLUSTER;;
	esac

	case $option in
		e11) kubectl_cluster=$KUBECTL_USE11_CLUSTER;;
		e12) kubectl_cluster=$KUBECTL_USE12_CLUSTER;;
		e21) kubectl_cluster=$KUBECTL_USE21_CLUSTER;;
		w21) kubectl_cluster=$KUBECTL_USW21_CLUSTER;;
	esac

	if [[ -z "$kubectl_cluster" ]]; then
		red_bar "Error: \`\$kubectl_cluster\` local var is undefined"
		return 1
	fi

	# `AWS_SSO_CACHE_DIR` can contain SSO creds for multiple roles
	# To identify creds for the current role, delete all creds,
	# then run a command to generate fresh SSO cred
	if [[ -d "$AWS_SSO_CACHE_DIR" ]]; then
		for file in "$AWS_SSO_CACHE_DIR"/*; do
			# Note: This folder also contains an OAuth cred, which needs to be preserved
			#       Deleting it causes the next command to re-initiate OAuth with AWS
			if [[ -f "$file" ]] && grep -q '"ProviderType": "britive"' "$file"; then
				rm "$file"
			fi
		done
	fi

	# Run a command to generate fresh SSO cred
	aws sts get-caller-identity

	# Find the current SSO cred (should be the only one now)
	local current_role
	for file in "$AWS_SSO_CACHE_DIR"/*; do
		if [[ -f "$file" ]] && grep -q '"ProviderType": "britive"' "$file"; then
			current_role=$(basename "$file")
			break
		fi
	done

	# Check if we found an SSO file
	if [[ -z "$current_role" ]]; then
		red_bar "Error: No SSO credentials file found in $AWS_SSO_CACHE_DIR"
		return 1
	fi

	cat <<-eof | pbcopy
		bind '"\e[A": history-search-backward'
		bind '"\e[B": history-search-forward'

		alias k='kubectl'
		alias kg='kubectl get'
		alias kd='kubectl describe'

		function kb () { kubectl exec -it "\$1" -- bash; }

		$(jq "$AWS_SSO_CACHE_JQ" "$AWS_SSO_CACHE_DIR/$current_role" | trim_list)

		aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name $kubectl_cluster
		kubectl config set-context --current --namespace=$GITHUB_DEFAULT_ORG
	eof

	echo
	green_bar 'History bindings and `kubectl` helpers copied to pasteboard'
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

function kubectl_keymap_f {
	local filters=("$@")

	args_keymap_s "${filters[@]}" < ~/Documents/zshrc-data/k8s.api-resources.txt
}

function kubectl_keymap_ff {
	# Save a copy for offline lookup
	kubectl api-resources > ~/Documents/zshrc-data/k8s.api-resources.txt
}

function kubectl_keymap_g {
	local params=("$@")

	kubectl get "${params[@]}"
}

function kubectl_keymap_gg {
	local params=("$@")

	kubectl get "${params[@]}" --output wide
}

function kubectl_keymap_h {
	[[ -z $1 ]] && return

	local filters=("$@")

	kubectl get pod | args_keymap_so "${filters[@]}"
}

function kubectl_keymap_hh {
	local filters=("$@")
	local columns="\
		NAME:.metadata.name,\
		STATUS:.status.phase,\
		READY:.status.containerStatuses[0].ready,\
		READINESS GATES:.status.conditions[?(@.type=='Ready')].status,\
		CREATED AT:.metadata.creationTimestamp,\
		RESTARTED AT:.status.containerStatuses[0].lastState.terminated.finishedAt"

	kubectl get pods -o custom-columns="$columns" |
		awk 'NR==1 {print; next} /False/ {gsub(/true/, "Ready"); gsub(/false/, "Unready"); gsub(/False/, "Unregistered"); print}' |
		column -t |
		args_keymap_so "${filters[@]}"
}

function kubectl_keymap_j {
	local params=("$@")

	# Save a copy in case original params is not deterministic b/c it references an arg number
	[[ -n ${params[*]} ]] && kubectl get "${params[@]}" --output json | tee ~/Documents/zshrc-data/k8s.get-output.json | jq
}

function kubectl_keymap_jj {
	cat ~/Documents/zshrc-data/k8s.get-output.json
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
	local pod="$1"

	kubectl edit pods "$pod"
}

function kubectl_keymap_n {
	local namespace=${1:-$GITHUB_DEFAULT_ORG}

	kubectl config set-context --current --namespace "$namespace"
}

function kubectl_keymap_p {
	local yaml_file="$1"

	helm template -f "$yaml_file" .
}

function kubectl_keymap_r {
	local resource_name="$1"

	kubectl rollout restart deployments "$resource_name"
}

function kubectl_keymap_rd {
	local resource_name="$1"

	kubectl rollout restart daemonsets "$resource_name"
}

function kubectl_keymap_rm {
	local pod="$1"

	kubectl delete pod "$pod"
}

function kubectl_keymap_rs {
	local resource_name="$1"

	kubectl rollout restart statefulsets "$resource_name"
}

function kubectl_keymap_s {
	local replica_count="$1"
	local deployment_name="$2"

	kubectl scale --replicas="$replica_count" deployments "$deployment_name"
}

function kubectl_keymap_t {
	[[ -z $1 ]] && return

	local filters=("$@")

	kubectl get deployments | args_keymap_so "${filters[@]}"
}

function kubectl_keymap_u {
	helm unittest --update-snapshot --file 'tests/*.yaml' .
}

function kubectl_keymap_v {
	local params=("$@")

	kubectl edit "${params[@]}"
}

function kubectl_keymap_w {
	local deployment="$1"

	kubectl edit deployments "$deployment"
}

function kubectl_keymap_w2 {
	# To be overwritten by `ZSHRC_SECRETS`
	return
}

function kubectl_keymap_y {
	local params=("$@")

	# Save a copy in case original params is not deterministic b/c it references an arg number
	[[ -n ${params[*]} ]] && kubectl get "${params[@]}" --output yaml | tee ~/Documents/zshrc-data/k8s.get-output.yaml | cat
}

function kubectl_keymap_yy {
	cat ~/Documents/zshrc-data/k8s.get-output.yaml
}
