# Post `tfl`
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
