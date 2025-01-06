#
# Namespace: [O]pen
#
OPEN_USAGE=(
  'o # Show this help'
	'o <key> <args>* # Invoke a key mapping'
)

OPEN_KEYMAP=(
	'o c <sha>? # Open specified commit, or fallback to the latest commit'
	'o g # Open page to create a new gist'
	'o n # Create new PR, then go to it'
	'o p <pr id> # Open specified PR, or fallback to `/pulls`'
	'o r <repo>? # Open specified repo, or fallback to the current working repo'
)

function o {
	local output; output="$(keymap_invoke ${#OPEN_KEYMAP} "${OPEN_KEYMAP[@]}" 'o' "$@")"

	if [[ -n $output ]]; then
		echo "$output" | ss
	else
		keymap_help ${#OPEN_USAGE} "${OPEN_USAGE[@]}" "${OPEN_KEYMAP[@]}"
	fi
}

#
# Key mappings
#

# To be overwritten by `.zshrc.secrets`
GIST='https://gist.github.com'

function o_c {
	open https://"$(domain)"/"$(org)"/"$(repo)"/commit/"$1"
}

function o_g {
	open $GIST
}

function o_n {
	gp && gh pr create --fill && gh pr view --web
}

function o_p {
	open https://"$(domain)"/"$(org)"/"$(repo)"/pull/"$1"
}

function o_r {
	open https://"$(domain)"/"$(org)"/"${*:-$(repo)}"
}
