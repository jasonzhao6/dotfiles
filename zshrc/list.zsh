#
# Lis[t]
#

LIST_USAGE=(
	't # Show all lists'
	't [list] [args]... # Select a list'
)

LIST_KEYMAPS=(
	't o # List Opal groups'
	't za [partial name] # List Zsh aliases'
	't zf [partial name] # List Zsh functions'
)

function t {
	local type_prefix=$1

	if [[ -z $type_prefix ]]; then
		keymaps_help "${LIST_USAGE[@]}" "${LIST_KEYMAPS[@]}" ${#LIST_USAGE}
	else
		for type in "${LIST_KEYMAPS[@]}"; do
			[[ $type == $type_prefix* ]] && $(echo "$type" | awk '{print $1}') "${@:2}"
		done
	fi
}

# To be overwritten by `.zshrc.secrets`
OPAL=(
	'non-secret-placeholder-1 url-1'
	'non-secret-placeholder-2 url-2'
)

function opal {
	print -l "${OPAL[@]}" | sort | column -t | ss
}

function zsh_aliases {
	alias | egrep ".*$1.*" | bw | ss
}

function zsh_functions {
	typeset -f | pgrep -o "^[\S]*$1[\S]* (?=\(\))" | bw | ss
}

#
# Helpers
#

[[ -n $ZSHRC_UNDER_TEST ]] && LIST_KEYMAPS+=('list_test <arg1> <arg2>')

function list_test {
	echo "arg1: $1"
	echo "arg2: $2"
}
