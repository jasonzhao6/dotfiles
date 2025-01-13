KUBECTL_NAMESPACE='kubectl_keymap'
KUBECTL_ALIAS='k'

KUBECTL_KEYMAP=(
	"$KUBECTL_ALIAS${KEYMAP_DOT}s # Save resources table"
	"$KUBECTL_ALIAS${KEYMAP_DOT}r # List resources"
	"$KUBECTL_ALIAS${KEYMAP_DOT}r <match>* <-mismatch>* # Filter resources"
	"$KUBECTL_ALIAS${KEYMAP_DOT}x <resource> # Explain a resource"
)

keymap_init $KUBECTL_NAMESPACE $KUBECTL_ALIAS "${KUBECTL_KEYMAP[@]}"

function kubectl_keymap {
	keymap_invoke $KUBECTL_NAMESPACE $KUBECTL_ALIAS ${#KUBECTL_KEYMAP} "${KUBECTL_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function kubectl_keymap_r {
	local filters=("$@")

	cat ~/Documents/k8.txt | args_keymap_s "${filters[@]}"
}

function kubectl_keymap_s {
	kubectl api-resources > ~/Documents/k8.txt
}

function kubectl_keymap_x {
	local resource="$1"

	kubectl explain "$resource"
}
