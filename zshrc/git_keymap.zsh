#
# Namespace: [G]it # TODO
# Alias: Git[H]ub
#

GIT_KEYMAP=(
	'h·on # Create a new PR, then open tab to it'
	'h·og # Open tab to create a new gist'
	''
	'h·oc # Open tab to the latest commit'
	'h·oc <sha> # Open tab to the specified commit'
	'h·op # Open tab to the latest PRs'
	'h·op <pr> # Open tab to the specified PR'
	'h·or # Open tab to the current repo'
	'h·or <repo> # Open tab to the specified repo'
)

function h {
	keymap h ${#GIT_KEYMAP} "${GIT_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function hoc {
	open https://"$(domain)"/"$(org)"/"$(repo)"/commit/"$1"
}

# To be overwritten by `$ZSH_SECRETS`
GIST='https://gist.github.com'

function hog {
	open $GIST
}

function hon {
	gp && gh pr create --fill && gh pr view --web
}

function hop {
	open https://"$(domain)"/"$(org)"/"$(repo)"/pull/"$1"
}

function hor {
	open https://"$(domain)"/"$(org)"/"${*:-$(repo)}"
}
