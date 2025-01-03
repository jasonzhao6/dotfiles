#
# [O]pen
#

O_TYPES=(
	main-branch
	new-pr
)

function o {
	# `$1` could be either a string containing urls or a type prefix, see 'Usage' below
	local urls; urls=$(echo "$@" | extract-urls)
	local type_prefix=$1

	if [[ -n $urls ]]; then
		echo "$urls" | while IFS= read -r url; do
			open "$url"
		done
	elif [[ -z $type_prefix ]]; then
		cat <<-eof

			Usage:

			  $(command-color 'o')
			  $(command-color 'o <url>')
			  $(command-color 'o <type> <arguments>?')
			  $(command-color 'o <type prefix> <arguments>?')

			Types:

		eof

		for type in "${O_TYPES[@]}"; do
			echo -n '  '
			command-color "${type/#/o }"
		done

		if [[ -n $O_UNDER_TEST ]]; then
			echo -n '  '
			command-color 'o test <arg1> <arg2>'
		fi
	else
		for type in "${O_TYPES[@]}"; do
			[[ $type == $type_prefix* ]] && "o-$type"
		done

		[[ 'test' == $type_prefix* ]] && o-test "${@:2}"
	fi
}

function o-main-branch {
	echo main
}

function o-new-pr {
	echo new
}

function o-test {
	echo "arg1: $1"
	echo "arg2: $2"
}
