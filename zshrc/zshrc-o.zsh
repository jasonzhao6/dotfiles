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

			  o main-branch
			  o new-pr
		eof
	else
		[[ 'main-branch' == $type_prefix* ]] && o-main-branch
		[[ 'new-pr' == $type_prefix* ]] && o-new-pr
	fi
}

function o-main-branch {
	echo main
}

function o-new-pr {
	echo new
}
