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
)

keymap_init $GIT_NAMESPACE $GIT_ALIAS "${GIT_KEYMAP[@]}"

function git_keymap {
	keymap_invoke $GIT_NAMESPACE $GIT_ALIAS ${#GIT_KEYMAP} "${GIT_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function git_keymap_oc {
	open https://"$(domain)"/"$(org)"/"$(repo)"/commit/"$1"
}

function git_keymap_op {
	open https://"$(domain)"/"$(org)"/"$(repo)"/pull/"$1"
}

function git_keymap_or {
	open https://"$(domain)"/"$(org)"/"${*:-$(repo)}"
}

function git_keymap_ng {
	pbpaste | gh gist create --web
}

function git_keymap_np {
	gp && gh pr create --fill && gh pr view --web
}
