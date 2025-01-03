#
# [O]pen
#

O_TYPES=(
	'commit-sha <sha>?'
	'main-branch <repo>?'
	'new-pull-request'
	'pull-request <id>'
)

[[ -n $UNDER_TEST ]] && O_TYPES+=('o_test <arg1> <arg2>')

function o {
	# `$1` could be either a string containing urls or a type prefix, see 'Usage' below
	local urls; urls=$(echo "$@" | extract_urls)
	local type_prefix=$1

	if [[ -n $urls ]]; then
		o_open_url
	elif [[ -z $type_prefix ]]; then
		o_print_usage
	else
		for type in "${O_TYPES[@]}"; do
			[[ $type == $type_prefix* ]] && $(echo "$type" | awk '{print $1}') "${@:2}"
		done
	fi
}

function commit-sha {
	open https://"$(domain)"/"$(org)"/"$(repo)"/commit/"$1"
}

function main-branch {
	open https://"$(domain)"/"$(org)"/"${*:-$(repo)}"
}

function new-pull-request {
	gp && gh pr create --fill && gh pr view --web
}

function pull-request {
	open https://"$(domain)"/"$(org)"/"$(repo)"/pull/"$1"
}

#
# Helpers
#

function o_open_url {
	echo "$urls" | while IFS= read -r url; do
		open "$url"
	done
}

function o_print_usage {
	cat <<-eof

		Usage:

		  $(command-color-dim 'o')
		  $(command-color-dim 'o <url>')
		  $(command-color-dim 'o <type> <arguments>?')
		  $(command-color-dim 'o <type prefix> <arguments>?')

		Types:

	eof

	for type in "${O_TYPES[@]}"; do
		echo -n '  '
		command-color "${type/#/o }"
	done
}

function o_test {
	echo "arg1: $1"
	echo "arg2: $2"
}
