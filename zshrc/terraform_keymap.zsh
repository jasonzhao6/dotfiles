TERRAFORM_NAMESPACE='terraform_keymap'
TERRAFORM_ALIAS='t'

TERRAFORM_KEYMAP=(
	"$TERRAFORM_ALIAS${KEYMAP_DOT}i # Init"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}iu # Init & upgrade"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}ir # Init & reconfigure"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}im # Init & migrate state"
	''
	"$TERRAFORM_ALIAS${KEYMAP_DOT}p (i,iu,ir,im)? # Plan"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}l (i,iu,ir,im)? # List states"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}o (i,iu,ir,im)? # Show output"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}n (i,iu,ir,im)? # Console"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}v (i,iu,ir,im)? # Validate"
	''
	"$TERRAFORM_ALIAS${KEYMAP_DOT}todo # Find manifests"
)

keymap_init $TERRAFORM_NAMESPACE $TERRAFORM_ALIAS "${TERRAFORM_KEYMAP[@]}"

function terraform_keymap {
	keymap_invoke $TERRAFORM_NAMESPACE $TERRAFORM_ALIAS \
		${#TERRAFORM_KEYMAP} "${TERRAFORM_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/terraform_helpers.zsh"

function terraform_keymap_i {
	mkdir -p ~/.terraform.cache; terraform init
}

function terraform_keymap_im {
	terraform init -migrate-state
}

function terraform_keymap_ir {
	terraform init -reconfigure
}

function terraform_keymap_iu {
	terraform init -upgrade
}

function terraform_keymap_l {
	local option=$1

	terraform_keymap_init "$option" && terraform state list | sed "s/.*/'&'/" | args_keymap_s
}

function terraform_keymap_n {
	local option=$1

	terraform_keymap_init "$option" && terraform console
}

function terraform_keymap_o {
	local option=$1

	terraform_keymap_init "$option" && terraform output
}

function terraform_keymap_p {
	local option=$1

	terraform_keymap_init "$option" && terraform plan -out=tfplan
}

function terraform_keymap_todo {
	find ~+ -name main.tf |
		grep --invert-match '\.terraform' |
		sed "s|$HOME|~|g" |
		trim 0 8 |
		args_keymap_s
}

function terraform_keymap_v {
	local option=$1

	terraform_keymap_init "$option" && terraform validate
}
