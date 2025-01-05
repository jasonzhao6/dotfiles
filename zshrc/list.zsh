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
	local keymap=$1

	local keymap_invoked;

	for line in "${LIST_KEYMAP[@]}"; do
		if [[ $line == "t $keymap "* ]]; then
			keymap_invoked=1
			"t_$keymap" "${@:2}"
		fi
	done

	[[ -z $keymap_invoked ]] && keymap_help "${LIST_USAGE[@]}" "${LIST_KEYMAP[@]}" ${#LIST_USAGE}
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
