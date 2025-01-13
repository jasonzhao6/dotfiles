# Post `tfi` (In case of init error, append ` i|iu|ir|im` to retry)
function terraform_keymap_p {
	terraform_keymap_pre "$@" && terraform plan -out=tfplan
}

function terraform_keymap_l {
	terraform_keymap_pre "$@" && terraform state list | sed "s/.*/'&'/" | args_keymap_s
}

function terraform_keymap_o {
	terraform_keymap_pre "$@" && terraform output
}

function terraform_keymap_n {
	terraform_keymap_pre "$@" && terraform console
}

function terraform_keymap_v {
	terraform_keymap_pre "$@" && terraform validate
}

# Post `tfp`
function terraform_keymap_a {
	terraform apply
}

function terraform_keymap_d {
	terraform destroy
}

function terraform_keymap_g {
	terraform show -bw tfplan | sed 's/user_data.*/user_data [REDACTED]/' | gh gist create --web
}

function terraform_keymap_z {
	terraform force-unlock "$@"
}

# Post `tfl`
function terraform_keymap_s {
	terraform state show "$@"
}

function terraform_keymap_t {
	terraform taint "$@"
}

function terraform_keymap_u {
	terraform untaint "$@"
}

function terraform_keymap_m {
	terraform state mv "$1" "$2"
}

function terraform_keymap_r {
	terraform state rm "$@"
}

# [F]ormat a file / folder
function terraform_keymap_f {
	terraform fmt -recursive "$@"
}

# [C]lear cache
function terraform_keymap_c {
	rm -rf tfplan .terraform ~/.terraform.d
}

function terraform_keymap_cc {
	rm -rf tfplan .terraform ~/.terraform.d ~/.terraform.cache
}

# Non-prod shortcut
function terraform_keymap_aa {
	terraform_keymap_pre "$@" && terraform apply -auto-approve
}


#
# Helpers
#

function terraform_keymap_ {
	pushd ~/gh/scratch/tf-debug > /dev/null || return

	if [[ -z $1 ]]; then
		terraform console
	else
		echo "local.$1" | terraform console
	fi

	popd > /dev/null || return
}
