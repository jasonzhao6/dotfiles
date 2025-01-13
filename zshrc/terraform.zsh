# Post `tfl`
# [F]ormat a file / folder

# Non-prod shortcut


#
# Helpers
#

function terraform_keymap_ {
	local var=$1

	pushd ~/gh/scratch/tf-debug > /dev/null || return

	if [[ -z $var ]]; then
		terraform console
	else
		echo "local.$var" | terraform console
	fi

	popd > /dev/null || return
}
