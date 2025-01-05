#
# Lis[t]
#

LIST_USAGE=(
	't # Show all lists'
	't [list] [args]... # Select a list'
)

LIST_KEYMAP=(
	't o # List Opal groups'
	't za [partial name] # List Zsh aliases'
	't zf [partial name] # List Zsh functions'
)

function t {
	local output; output="$(keymap_invoke ${#LIST_KEYMAP} "${LIST_KEYMAP[@]}" 't' "$@")"

	if [[ -n $output ]]; then
		echo "$output"
	else
		keymap_help "${LIST_USAGE[@]}" "${LIST_KEYMAP[@]}" ${#LIST_USAGE}
	fi
}

# To be overwritten by `.zshrc.secrets`
OPAL=(
	'non-secret-placeholder-1 url-1'
	'non-secret-placeholder-2 url-2'
)

function t_o {
	print -l "${OPAL[@]}" | sort | column -t | ss
}

function t_za {
	alias | egrep ".*$1.*" | bw | ss
}

function t_zf {
	typeset -f | pgrep -o "^[\S]*$1[\S]* (?=\(\))" | bw | ss
}

#
# Helpers
#

# Intentionally testing lack of `#` comment in the keymap string
[[ -n $ZSHRC_UNDER_TEST ]] && LIST_KEYMAP+=('t test [arg1] [arg2]')

function t_test {
	echo "arg1: $1"
	echo "arg2: $2"
}
