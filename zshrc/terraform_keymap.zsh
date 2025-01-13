TERRAFORM_NAMESPACE='terraform_keymap'
TERRAFORM_ALIAS='t'

TERRAFORM_KEYMAP=(
	"$TERRAFORM_ALIAS${KEYMAP_DOT}todo # Find manifests"
)

keymap_init $TERRAFORM_NAMESPACE $TERRAFORM_ALIAS "${TERRAFORM_KEYMAP[@]}"

function terraform_keymap {
	keymap_invoke $TERRAFORM_NAMESPACE $TERRAFORM_ALIAS ${#TERRAFORM_KEYMAP} "${TERRAFORM_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function terraform_keymap_todo {
	find ~+ -name main.tf |
		grep --invert-match '\.terraform' |
		sed "s|$HOME|~|g" |
		trim 0 8 |
		args_keymap_s
}
