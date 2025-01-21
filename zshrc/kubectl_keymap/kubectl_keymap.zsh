KUBECTL_NAMESPACE='kubectl_keymap'
KUBECTL_ALIAS='k'
KUBECTL_DOT="${KUBECTL_ALIAS}${KEYMAP_DOT}"

KUBECTL_KEYMAP=(
	"${KUBECTL_ALIAS} <kubectl command>"
	''
	"${KUBECTL_DOT}s # Save a copy of resource types"
	"${KUBECTL_DOT}r # List resource types"
	"${KUBECTL_DOT}r <match>* <-mismatch>* # Filter resource types"
	"${KUBECTL_DOT}x <resource type> # Explain a resource type"
	''
	"${KUBECTL_DOT}n <name> # Set namespace"
	''
	"${KUBECTL_DOT}u <command> # Alias for \`kubectl\`"
	"${KUBECTL_DOT}e <command> # Exec a command"
	"${KUBECTL_DOT}g <resource type> # Get resources"
	"${KUBECTL_DOT}k <resource type> # Get resources as args"
	"${KUBECTL_DOT}d <command> # Describe resource(s)"
	''
	"${KUBECTL_DOT}b <pod> # Exec into bash"
	"${KUBECTL_DOT}c <pod> # Exec a command"
	"${KUBECTL_DOT}l <pod> # Show logs"
	''
	"${KUBECTL_DOT}j <command> # Get resource as json & save a copy"
	"${KUBECTL_DOT}jj <command> # Get the copy of json"
	"${KUBECTL_DOT}y <command> # Get resource as yaml & save a copy"
	"${KUBECTL_DOT}yy <command> # Get the copy of yaml"
)

keymap_init $KUBECTL_NAMESPACE $KUBECTL_ALIAS "${KUBECTL_KEYMAP[@]}"

source "$ZSHRC_DIR/$KUBECTL_NAMESPACE/kubectl_commands.zsh"

function kubectl_keymap {
	# If the first arg is a `kubectl` command, pass it through
	for command in "${KUBECTL_COMMANDS[@]}"; do
		if [[ $command == $1 ]]; then
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

function kubectl_keymap_g {
	local resource="$1"

	kubectl get "$resource"
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

function kubectl_keymap_u {
	local command=("$@")

	kubectl "${command[@]}"
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
