#
# Namespace: Lis[t]s
#

LISTS_KEYMAP=(
	't o <substring>? # List Opal groups'
	't za <substring>? # List Zsh aliases'
	't zf <substring>? # List Zsh functions'
)

function t {
	local namespace='t'
	local output; output="$(keymap $namespace ${#LISTS_KEYMAP} "${LISTS_KEYMAP[@]}" "$@")"
	local exit_code=$?; [[ $exit_code -eq 0 ]] && echo "$output" | ss || echo "$output"
}

#
# Key mappings
#

# To be overwritten by `.zshrc.secrets`
OPAL=(
	'non-secret-placeholder-1 url-1'
	'non-secret-placeholder-2 url-2'
)

function t_o {
	print -l "${OPAL[@]}" | sort | column -t | contain "$1"
}

function t_za {
	alias | contain "$1"
}

function t_zf {
	# Trim the trailing ` () {` function definition suffix
	typeset -f | grep ' () {' | contain "$1" | trim 0 5
}
