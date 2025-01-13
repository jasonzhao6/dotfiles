# Post `tfp`
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
	terraform_keymap_init "$@" && terraform apply -auto-approve
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
