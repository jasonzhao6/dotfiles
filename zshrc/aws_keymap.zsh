#
# Namespace: A[W]S
#

AWS_KEYMAP=(
	'w·o # List Opal groups'
	'w·o <match> # Filter Opal groups'
)

function w {
	keymap w ${#AWS_KEYMAP} "${AWS_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

# To be overwritten by `.zshrc.secrets`
OPAL=(
	'non-secret-placeholder-1 url-1'
	'non-secret-placeholder-2 url-2'
)

function wo {
	print -l "${OPAL[@]}" | sort | column -t | contain "$1" | as
}
