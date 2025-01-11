AWS_NAMESPACE='aws_keymap'
AWS_ALIAS='s'

AWS_KEYMAP=(
	"$AWS_ALIAS·o # List Opal groups"
	"$AWS_ALIAS·o <match> # Filter Opal groups"
	"$AWS_ALIAS·sup <match> # Filter Opal groups"
)

keymap_init $AWS_NAMESPACE $AWS_ALIAS "${AWS_KEYMAP[@]}"

function aws_keymap {
	keymap_invoke $AWS_NAMESPACE $AWS_ALIAS ${#AWS_KEYMAP} "${AWS_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

# To be overwritten by `$ZSH_SECRETS`
AWS_OPAL=(
	'non-secret-placeholder-1 url-1'
	'non-secret-placeholder-2 url-2'
)

function aws_keymap_o {
	print -l "${AWS_OPAL[@]}" | sort | column -t | contain "$1" | args_keymap_s
}
