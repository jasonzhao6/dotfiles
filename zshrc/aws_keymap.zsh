#
# Namespace: AWS
#

# This file should define 1 `<namespace>` and many `<namespace>_<key>` functions
AWS_NAMESPACE='aws'

# The `<namespace>` function will be aliased to `<alias>`
# The `<namespace>_<key>` functions will be aliased to `<alias><key>`
# This `<alias>` is expected to be a single character
AWS_ALIAS='w'

AWS_KEYMAP=(
	"$AWS_ALIAS·o # List Opal groups"
	"$AWS_ALIAS·o <match> # Filter Opal groups"
	"$AWS_ALIAS·sup <match> # Filter Opal groups"
)

function aws {
	keymap $AWS_ALIAS ${#AWS_KEYMAP} "${AWS_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

# To be overwritten by `$ZSH_SECRETS`
OPAL=(
	'non-secret-placeholder-1 url-1'
	'non-secret-placeholder-2 url-2'
)

function aws_o {
	print -l "${OPAL[@]}" | sort | column -t | contain "$1" | as
}

function aws_sup {
	echo -n 'caller: '
	caller
	
	echo -n 'callee: '
	callee
}
