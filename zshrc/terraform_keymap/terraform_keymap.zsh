TERRAFORM_NAMESPACE='terraform_keymap'
TERRAFORM_ALIAS='t'
TERRAFORM_DOT="${TERRAFORM_ALIAS}${KEYMAP_DOT}"

TERRAFORM_KEYMAP=(
	"${TERRAFORM_ALIAS} {terraform command}"
	''
	"${TERRAFORM_DOT}w # List manifests"
	"${TERRAFORM_DOT}w {match}* {-mismatch}* # Filter manifests"
	''
	"${TERRAFORM_DOT}i # Init"
	"${TERRAFORM_DOT}iu # Init & upgrade"
	"${TERRAFORM_DOT}ir # Init & reconfigure"
	"${TERRAFORM_DOT}im # Init & migrate state"
	"${TERRAFORM_DOT}e # Load secret env vars"
	''
	"${TERRAFORM_DOT}v {i,iu,ir,im,e}? # Validate"
	"${TERRAFORM_DOT}p {i,iu,ir,im,e}? # Plan"
	"${TERRAFORM_DOT}g # Upload gist"
	"${TERRAFORM_DOT}z # Unlock"
	"${TERRAFORM_DOT}a # Apply"
	"${TERRAFORM_DOT}d # Destroy"
	"${TERRAFORM_DOT}o # Show output"
	''
	"${TERRAFORM_DOT}l # List states"
	"${TERRAFORM_DOT}s {name} # Show state"
	"${TERRAFORM_DOT}t {name} # Taint state"
	"${TERRAFORM_DOT}u {name} # Untaint state"
	"${TERRAFORM_DOT}m {before} {after} # Move state"
	"${TERRAFORM_DOT}rm {name} # Remove state"
	''
	"${TERRAFORM_DOT}f # Format"
	"${TERRAFORM_DOT}h # Scratch"
	"${TERRAFORM_DOT}n # Console"
	"${TERRAFORM_DOT}c # Clean"
	"${TERRAFORM_DOT}cc # Clean & clear plugin cache"
	"${TERRAFORM_DOT}qa # Apply & auto-approve"
)

keymap_init $TERRAFORM_NAMESPACE $TERRAFORM_ALIAS "${TERRAFORM_KEYMAP[@]}"

source "$ZSHRC_DIR/$TERRAFORM_NAMESPACE/terraform_commands.zsh"

function terraform_keymap {
	# If the first arg is a `terraform` command, pass it through
	for command in "${TERRAFORM_COMMANDS[@]}"; do
		if [[ $command == "$1" ]]; then
			terraform "$@"
			return
		fi
	done

	keymap_show $TERRAFORM_NAMESPACE $TERRAFORM_ALIAS \
		${#TERRAFORM_KEYMAP} "${TERRAFORM_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/$TERRAFORM_NAMESPACE/terraform_helpers.zsh"

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

# To be overwritten by `ZSHRC_SECRETS`
TERRAFORM_VARS=(
	'var_name_1 secret_name_1'
	'var_name_2 secret_name_2'
)

function terraform_keymap_e {
	local fields
	local var_name
	local secret_name

	for var in "${TERRAFORM_VARS[@]}"; do
		fields=("${=var}")
		var_name="TF_VAR_${fields[1]}"
		secret_name="${fields[2]}"

		echo_eval "export $var_name=\$(aws_keymap_m $secret_name)"

		# If env var was not set, exit with error
		[[ -z ${(P)var_name} ]] && return 1
	done

	return 0
}

function terraform_keymap_f {
	local target_path=${1:-.}

	terraform fmt -recursive "$target_path"
}
function terraform_keymap_g {
	terraform show -bw tfplan | sed 's/user_data.*/user_data [REDACTED]/' | gh gist create --web
}

function terraform_keymap_h {
	local var=$1

	pushd ~/github/jasonzhao6/scratch/tf-debug > /dev/null || return

	if [[ -z $var ]]; then
		terraform console
	else
		echo "local.$var" | terraform console
	fi

	popd > /dev/null || return
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

	terraform state list | sed "s/.*/'&'/" | args_keymap_s
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

function terraform_keymap_u {
	local state=$1

	terraform untaint "$state"
}

function terraform_keymap_v {
	local option=$1

	terraform_keymap_init "$option" && terraform validate
}

function terraform_keymap_w {
	local filters=("$@")

	ls -- **/main.tf | trim 0 8 | args_keymap_s "${filters[@]}"
}

function terraform_keymap_z {
	local id=$1

	terraform force-unlock "$id"
}
