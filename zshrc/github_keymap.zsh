GITHUB_NAMESPACE='github_keymap'
GITHUB_ALIAS='h'

GITHUB_KEYMAP=(
	"$GITHUB_ALIAS${KEYMAP_DOT}np # Create a new PR, then open tab to it"
	"$GITHUB_ALIAS${KEYMAP_DOT}ng # Create a new gist, then open tab to it"
	''
	"$GITHUB_ALIAS${KEYMAP_DOT}oc # Open tab to the latest commit"
	"$GITHUB_ALIAS${KEYMAP_DOT}oc <sha> # Open tab to the specified commit"
	"$GITHUB_ALIAS${KEYMAP_DOT}op # Open tab to the latest PRs"
	"$GITHUB_ALIAS${KEYMAP_DOT}op <pr> # Open tab to the specified PR"
	"$GITHUB_ALIAS${KEYMAP_DOT}or # Open tab to the current repo"
	"$GITHUB_ALIAS${KEYMAP_DOT}or <repo> # Open tab to the specified repo"
	''
	"$GITHUB_ALIAS${KEYMAP_DOT}nd # Repo domain"
	"$GITHUB_ALIAS${KEYMAP_DOT}no # Repo org"
	"$GITHUB_ALIAS${KEYMAP_DOT}nr # Repo name"
	"$GITHUB_ALIAS${KEYMAP_DOT}nb # Repo branch"
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
