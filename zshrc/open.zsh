#
# [O]pen
#

OPEN_TYPES=(
	'commit-sha <sha>?'
	'gist'
	'main-branch <repo>?'
	'new-pull-request'
	'pull-request <id>'
)

function o {
	# `$1` could be either a string containing urls or a type prefix, see `open_usage`
	local urls; urls=$(echo "$@" | extract_urls)
	local type_prefix=$1

	if [[ -n $urls ]]; then
		open_url
	elif [[ -z $type_prefix ]]; then
		open_usage
	else
		for type in "${OPEN_TYPES[@]}"; do
			[[ $type == $type_prefix* ]] && $(echo "$type" | awk '{print $1}') "${@:2}"
		done
	fi
}

# To be overwritten by `.zshrc.secrets`
GIST='https://gist.github.com'

function gist {
	open $GIST
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

function open_url {
	echo "$urls" | while IFS= read -r url; do
		open "$url"
	done
}

function open_usage {
	cat <<-eof

		Usage:

		  $(command_color_dim 'o')
		  $(command_color_dim 'o <url>')
		  $(command_color_dim 'o <type> <arguments>?')
		  $(command_color_dim 'o <type prefix> <arguments>?')

		Types:

	eof

	for type in "${OPEN_TYPES[@]}"; do
		echo -n '  '
		command_color "${type/#/o }"
	done
}

[[ -n $ZSHRC_UNDER_TEST ]] && OPEN_TYPES+=('open_test <arg1> <arg2>')

function open_test {
	echo "arg1: $1"
	echo "arg2: $2"
}
