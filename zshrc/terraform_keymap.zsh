TERRAFORM_NAMESPACE='terraform_keymap'
TERRAFORM_ALIAS='t'

TERRAFORM_KEYMAP=(
	"$TERRAFORM_ALIAS${KEYMAP_DOT}i # Init"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}iu # Init & upgrade"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}ir # Init & reconfigure"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}im # Init & migrate state"
	''
	"$TERRAFORM_ALIAS${KEYMAP_DOT}v (i,iu,ir,im)? # Validate"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}p (i,iu,ir,im)? # Plan"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}g # Plan -> gist"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}z # Unlock"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}a # Apply"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}d # Destroy"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}o # Show output"
	''
	"$TERRAFORM_ALIAS${KEYMAP_DOT}l (i,iu,ir,im)? # List states"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}s <name> # Show state"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}t <name> # Taint state"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}u <name> # Untaint state"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}m <before> <after> # Move state"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}rm <name> # Remove state"
	''
	"$TERRAFORM_ALIAS${KEYMAP_DOT}f # Format"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}n # Console"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}c # Clean"
	"$TERRAFORM_ALIAS${KEYMAP_DOT}cc # Clean & clear plugin cache"
	''
	"$TERRAFORM_ALIAS${KEYMAP_DOT}qa # Apply & auto-approve"
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

function terraform_keymap_a {
	terraform apply
}

function terraform_keymap_c {
	rm -rf tfplan .terraform ~/.terraform.d
}

function terraform_keymap_cc {
	rm -rf tfplan .terraform ~/.terraform.d ~/.terraform.cache
}

function terraform_keymap_d {
	terraform destroy
}

function terraform_keymap_f {
	local target_path=${1:-.}

	terraform fmt -recursive "$target_path"
}
function terraform_keymap_g {
	terraform show -bw tfplan | sed 's/user_data.*/user_data [REDACTED]/' | gh gist create --web
}

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

function terraform_keymap_m {
	terraform state mv "$1" "$2"
}

function terraform_keymap_n {
	terraform console
}

function terraform_keymap_o {
	terraform output
}

function terraform_keymap_p {
	local option=$1

	terraform_keymap_init "$option" && terraform plan -out=tfplan
}

function terraform_keymap_qa {
	terraform apply -auto-approve
}

function terraform_keymap_rm {
	local state=$1

	terraform state rm "$state"
}

function terraform_keymap_s {
	local state=$1

	terraform state show "$state"
}

function terraform_keymap_t {
	local state=$1

	terraform taint "$state"
}

function terraform_keymap_todo {
	find ~+ -name main.tf |
		grep --invert-match '\.terraform' |
		sed "s|$HOME|~|g" |
		trim 0 8 |
		args_keymap_s
}

function terraform_keymap_u {
	local state=$1

	terraform untaint "$state"
}

function terraform_keymap_v {
	local option=$1

	terraform_keymap_init "$option" && terraform validate
}

function terraform_keymap_z {
	local id=$1

	terraform force-unlock "$id"
}
