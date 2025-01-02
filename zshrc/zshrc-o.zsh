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

			  o <string containing urls>
			  o <type> <arguments>*
			  o <type prefix> <arguments>*

			Types:

			  # o main-branch
			  # o new-pr
		eof
	else
		[[ 'new-pr' == $type_prefix* ]] && o_new_pr
	fi
}

function o_new_pr {
	echo todo
}
