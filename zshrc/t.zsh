#
# Lis[t]
#

T_TYPES=(
	'opal'
)

[[ -n $UNDER_TEST ]] && T_TYPES+=('t_test <arg1> <arg2>')

function t {
	local type_prefix=$1

	if [[ -z $type_prefix ]]; then
		t_print_usage
	else
		for type in "${T_TYPES[@]}"; do
			[[ $type == $type_prefix* ]] && $(echo "$type" | awk '{print $1}') "${@:2}"
		done
	fi
}

OPAL=(
	'non-secret-placeholder-1 url-1'
	'non-secret-placeholder-2 url-2'
	'non-secret-placeholder-3 url-3'
)

function opal {
	print -l "${OPAL[@]}" | sort | column -t | ss
}

#
# Helpers
#

function t_print_usage {
	cat <<-eof

		Usage:

		  $(command-color-dim 't')
		  $(command-color-dim 't <type> <arguments>?')
		  $(command-color-dim 't <type prefix> <arguments>?')

		Types:

	eof

	for type in "${T_TYPES[@]}"; do
		echo -n '  '
		command-color "${type/#/t }"
	done
}

function t_test {
	echo "arg1: $1"
	echo "arg2: $2"
}
