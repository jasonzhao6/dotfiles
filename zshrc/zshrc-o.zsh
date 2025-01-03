#
# [O]pen
#

function o {
	local urls=$(echo $@ | extract-urls)
	local type_prefix=$1

	if [[ -n $urls ]]; then
		echo "$urls" | while IFS= read -r url; do
			open $url
		done
	elif [[ -z $type_prefix ]]; then
		cat <<-eof

			Usage:

			  o
			  o <url>
			  o <type> <arguments>?
			  o <type prefix> <arguments>?

			Types:
			  $([[ -n $O_UNDER_TEST ]] && echo -n 'o test <arg1> <arg2>')

			  o main-branch
			  o new-pr
		eof
	else
		[[ 'test' == $type_prefix* ]] && o-test "${@:2}"

		[[ 'main-branch' == $type_prefix* ]] && o-main-branch
		[[ 'new-pr' == $type_prefix* ]] && o-new-pr
	fi
}

function o-test {
	echo "arg1: $1"
	echo "arg2: $2"
}

function o-main-branch {
	echo main
}

function o-new-pr {
	echo new
}
