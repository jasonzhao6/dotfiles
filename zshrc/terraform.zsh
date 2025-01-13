# Post `tfl`
# [F]ormat a file / folder

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
