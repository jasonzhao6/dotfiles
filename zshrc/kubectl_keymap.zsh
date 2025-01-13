KUBECTL_NAMESPACE='kubectl_keymap'
KUBECTL_ALIAS='k'

KUBECTL_KEYMAP=(
	"$KUBECTL_ALIAS${KEYMAP_DOT}s # Save resource types data"
	"$KUBECTL_ALIAS${KEYMAP_DOT}r # List resource types"
	"$KUBECTL_ALIAS${KEYMAP_DOT}r <match>* <-mismatch>* # Filter resource types"
	"$KUBECTL_ALIAS${KEYMAP_DOT}x <resource type> # Explain a resource type"
	''
	"$KUBECTL_ALIAS${KEYMAP_DOT}n <name> # Set namespace"
	''
	"$KUBECTL_ALIAS${KEYMAP_DOT}u <command> # Alias for \`kubectl\`"
	"$KUBECTL_ALIAS${KEYMAP_DOT}e <command> # Exec a command"
	"$KUBECTL_ALIAS${KEYMAP_DOT}g <resource type> # Get resources"
	"$KUBECTL_ALIAS${KEYMAP_DOT}k <resource type> # Get resources as args"
	"$KUBECTL_ALIAS${KEYMAP_DOT}d <command> # Describe resource(s)"
	''
	"$KUBECTL_ALIAS${KEYMAP_DOT}b <pod> # Exec into bash"
	"$KUBECTL_ALIAS${KEYMAP_DOT}c <pod> # Exec a command"
	"$KUBECTL_ALIAS${KEYMAP_DOT}l <pod> # Show logs"
	''
	"$KUBECTL_ALIAS${KEYMAP_DOT}j <command> # Get resource as json"
	"$KUBECTL_ALIAS${KEYMAP_DOT}jj <command> # Cat cached copy of json"
	"$KUBECTL_ALIAS${KEYMAP_DOT}y <command> # Get resource as yaml"
	"$KUBECTL_ALIAS${KEYMAP_DOT}yy <command> # Cat cached copy of yaml"
)

keymap_init $KUBECTL_NAMESPACE $KUBECTL_ALIAS "${KUBECTL_KEYMAP[@]}"

function kubectl_keymap {
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

	[[ -n ${command[*]} ]] && kubectl get "${command[@]}" -o json | tee ~/Documents/k8.json | jq
}

function kubectl_keymap_jj {
	cat ~/Documents/k8.json
}

function kubectl_keymap_k {
	local resource="$1"

	kubectl get "$resource" | args_keymap_so
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

#	cat ~/Documents/k8.txt | args_keymap_s "${filters[@]}"
	args_keymap_s "${filters[@]}" < ~/Documents/k8.txt
}

function kubectl_keymap_s {
	kubectl api-resources > ~/Documents/k8.txt
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

	[[ -n ${command[*]} ]] && kubectl get "${command[@]}" -o yaml | tee ~/Documents/k8.yaml | cat
}

function kubectl_keymap_yy {
	cat ~/Documents/k8.yaml
}
