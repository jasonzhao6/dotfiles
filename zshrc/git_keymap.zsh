GIT_NAMESPACE='git_keymap'
GIT_ALIAS='h'

GIT_KEYMAP=(
	"$GIT_ALIAS·np # Create a new PR, then open tab to it"
	"$GIT_ALIAS·ng # Create a new gist, then open tab to it"
	''
	"$GIT_ALIAS·oc # Open tab to the latest commit"
	"$GIT_ALIAS·oc <sha> # Open tab to the specified commit"
	"$GIT_ALIAS·op # Open tab to the latest PRs"
	"$GIT_ALIAS·op <pr> # Open tab to the specified PR"
	"$GIT_ALIAS·or # Open tab to the current repo"
	"$GIT_ALIAS·or <repo> # Open tab to the specified repo"
	''
	"$GIT_ALIAS·nd # Git domain name"
	"$GIT_ALIAS·no # Git org name"
	"$GIT_ALIAS·nr # Git repo name"
	"$GIT_ALIAS·nb # Git branch name"
)

keymap_init $GIT_NAMESPACE $GIT_ALIAS "${GIT_KEYMAP[@]}"

function git_keymap {
	keymap_invoke $GIT_NAMESPACE $GIT_ALIAS ${#GIT_KEYMAP} "${GIT_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function git_keymap_nb {
	git rev-parse --abbrev-ref HEAD
}

function git_keymap_nd {
	git remote get-url origin | sed 's/.*[:/]\([^/]*\)\/.*\/.*/\1/'
}

function git_keymap_ng {
	pbpaste | gh gist create --web
}

function git_keymap_no {
	git remote get-url origin | sed 's/.*[:/]\([^/]*\)\/.*/\1/'
}

function git_keymap_np {
	gp && gh pr create --fill && gh pr view --web
}

function git_keymap_nr {
	git rev-parse --show-toplevel | xargs basename
}

function git_keymap_oc {
	open https://"$(git_keymap_nd)"/"$(git_keymap_no)"/"$(git_keymap_nr)"/commit/"$1"
}

function git_keymap_op {
	open https://"$(git_keymap_nd)"/"$(git_keymap_no)"/"$(git_keymap_nr)"/pull/"$1"
}

function git_keymap_or {
	open https://"$(git_keymap_nd)"/"$(git_keymap_no)"/"${*:-$(git_keymap_nr)}"
}
