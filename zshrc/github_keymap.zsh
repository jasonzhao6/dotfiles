GITHUB_NAMESPACE='github_keymap'
GITHUB_ALIAS='h'

GITHUB_KEYMAP=(
	"$GITHUB_ALIAS·np # Create a new PR, then open tab to it"
	"$GITHUB_ALIAS·ng # Create a new gist, then open tab to it"
	''
	"$GITHUB_ALIAS·oc # Open tab to the latest commit"
	"$GITHUB_ALIAS·oc <sha> # Open tab to the specified commit"
	"$GITHUB_ALIAS·op # Open tab to the latest PRs"
	"$GITHUB_ALIAS·op <pr> # Open tab to the specified PR"
	"$GITHUB_ALIAS·or # Open tab to the current repo"
	"$GITHUB_ALIAS·or <repo> # Open tab to the specified repo"
	''
	"$GITHUB_ALIAS·nd # Repo domain"
	"$GITHUB_ALIAS·no # Repo org"
	"$GITHUB_ALIAS·nr # Repo name"
	"$GITHUB_ALIAS·nb # Repo branch"
)

keymap_init $GITHUB_NAMESPACE $GITHUB_ALIAS "${GITHUB_KEYMAP[@]}"

function github_keymap {
	keymap_invoke $GITHUB_NAMESPACE $GITHUB_ALIAS ${#GITHUB_KEYMAP} "${GITHUB_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function github_keymap_nb {
	git rev-parse --abbrev-ref HEAD
}

function github_keymap_nd {
	git remote get-url origin | sed 's/.*[:/]\([^/]*\)\/.*\/.*/\1/'
}

function github_keymap_ng {
	pbpaste | gh gist create --web
}

function github_keymap_no {
	git remote get-url origin | sed 's/.*[:/]\([^/]*\)\/.*/\1/'
}

function github_keymap_np {
	gp && gh pr create --fill && gh pr view --web
}

function github_keymap_nr {
	git rev-parse --show-toplevel | xargs basename
}

function github_keymap_oc {
	open https://"$(github_keymap_nd)"/"$(github_keymap_no)"/"$(github_keymap_nr)"/commit/"$1"
}

function github_keymap_op {
	open https://"$(github_keymap_nd)"/"$(github_keymap_no)"/"$(github_keymap_nr)"/pull/"$1"
}

function github_keymap_or {
	open https://"$(github_keymap_nd)"/"$(github_keymap_no)"/"${*:-$(github_keymap_nr)}"
}
