KUBECTL_NAMESPACE='kubectl_keymap'
KUBECTL_ALIAS='k'

KUBECTL_KEYMAP=(
	"$KUBECTL_ALIAS${KEYMAP_DOT}s # Save resources table"
	"$KUBECTL_ALIAS${KEYMAP_DOT}r # List resources"
	"$KUBECTL_ALIAS${KEYMAP_DOT}r <match>* <-mismatch>* # Filter resources"
	"$KUBECTL_ALIAS${KEYMAP_DOT}x <resource> # Explain a resource"
	''
	"$KUBECTL_ALIAS${KEYMAP_DOT}n <name> # Set namespace"
	''
	"$KUBECTL_ALIAS${KEYMAP_DOT}u <command> # Alias for \`kubectl\`"
	"$KUBECTL_ALIAS${KEYMAP_DOT}e <command> # Exec"
	"$KUBECTL_ALIAS${KEYMAP_DOT}g <resource> # Get"
	"$KUBECTL_ALIAS${KEYMAP_DOT}k <resource> # Get as args"
	"$KUBECTL_ALIAS${KEYMAP_DOT}d <resource> # Describe"
)

keymap_init $KUBECTL_NAMESPACE $KUBECTL_ALIAS "${KUBECTL_KEYMAP[@]}"

function kubectl_keymap {
	keymap_invoke $KUBECTL_NAMESPACE $KUBECTL_ALIAS ${#KUBECTL_KEYMAP} "${KUBECTL_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function kubectl_keymap_d {
	local resource="$1"

	kubectl describe "$resource"
}

function kubectl_keymap_e {
	local command=("$@")

	kubectl exec "${command[@]}"
}

function kubectl_keymap_g {
	local resource="$1"

	kubectl get "$resource"
}

function kubectl_keymap_k {
	local resource="$1"

	kubectl get "$resource" | s
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
