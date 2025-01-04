#
# Lis[t]
#

LIST_TYPES=(
	'opal'
	'zsh_aliases <partial match>'
	'zsh_functions <partial match>'
)

function t {
	local type_prefix=$1

	if [[ -z $type_prefix ]]; then
		list_usage
	else
		for type in "${LIST_TYPES[@]}"; do
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
	typeset -f | pcregrep -o "^[\S]*$1[\S]* (?=\(\))" | bw | ss
}

#
# Helpers
#

function list_usage {
	cat <<-eof

		Usage:

		  $(command_color_dim 't')
		  $(command_color_dim 't <type> <args>?')
		  $(command_color_dim 't <type prefix> <args>?')

		Types:

	eof

	for type in "${LIST_TYPES[@]}"; do
		echo -n '  '
		command_color "${type/#/t }"
	done
}

[[ -n $ZSHRC_UNDER_TEST ]] && LIST_TYPES+=('list_test <arg1> <arg2>')

function list_test {
	echo "arg1: $1"
	echo "arg2: $2"
}
