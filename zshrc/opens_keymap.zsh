#
# Namespace: [O]pens
#

OPENS_KEYMAP=(
	'o c <sha>? # Open the specified commit, or fallback to the latest commit'
	'o g # Open tab to create a new gist'
	'o n # Create a new PR, then go to it'
	'o p <pr id> # Open the specified PR, or fallback to `/pulls`'
	'o r <repo>? # Open the specified repo, or fallback to the current working repo'
)

function o {
	local namespace='o'
	local output; output="$(keymap $namespace ${#OPENS_KEYMAP} "${OPENS_KEYMAP[@]}" "$@")"
	local exit_code=$?; [[ $exit_code -eq 0 ]] && echo "$output" | ss || echo "$output"
}

#
# Key mappings
#

function o_c {
	open https://"$(domain)"/"$(org)"/"$(repo)"/commit/"$1"
}

# To be overwritten by `.zshrc.secrets`
GIST='https://gist.github.com'

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
