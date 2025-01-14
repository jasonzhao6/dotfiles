GITHUB_NAMESPACE='github_keymap'
GITHUB_ALIAS='h'
GITHUB_DOT="${GITHUB_ALIAS}${KEYMAP_DOT}"

GITHUB_KEYMAP=(
	"${GITHUB_DOT}j # Create a new PR, then open it"
	"${GITHUB_DOT}g # Create a new gist, then open it"
	''
	"${GITHUB_DOT}h # Open the current repo"
	"${GITHUB_DOT}h <repo> # Open the specified repo"
	"${GITHUB_DOT}p # Open the latest PRs"
	"${GITHUB_DOT}p <pr> # Open the specified PR"
	"${GITHUB_DOT}c # Open the latest commit"
	"${GITHUB_DOT}c <sha> # Open the specified commit"
	''
	"${GITHUB_DOT}s # Save repos data"
	"${GITHUB_DOT}r # List repos"
	"${GITHUB_DOT}r <match>* <-mismatch>* # Filter repos"
	"${GITHUB_DOT}n # Navigate to repo directory"
	''
	"${GITHUB_DOT}d # Domain name"
	"${GITHUB_DOT}o # Org name"
	"${GITHUB_DOT}re # Repo name"
	"${GITHUB_DOT}b # Branch name"
)

keymap_init $GITHUB_NAMESPACE $GITHUB_ALIAS "${GITHUB_KEYMAP[@]}"

function github_keymap {
	keymap_invoke $GITHUB_NAMESPACE $GITHUB_ALIAS ${#GITHUB_KEYMAP} "${GITHUB_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function github_keymap_b {
	git rev-parse --abbrev-ref HEAD
}

function github_keymap_c {
	open https://"$(github_keymap_d)"/"$(github_keymap_o)"/"$(github_keymap_r)"/commit/"$1"
}

function github_keymap_d {
	git remote get-url origin | sed 's/.*[:/]\([^/]*\)\/.*\/.*/\1/'
}

function github_keymap_g {
	pbpaste | gh gist create --web
}

function github_keymap_h {
	open https://"$(github_keymap_d)"/"$(github_keymap_o)"/"${*:-$(github_keymap_r)}"
}

function github_keymap_l {
	gh repo list "$(github_keymap_o)" --no-archived --limit 1000 --json name |
		jq -r '.[].name' |
		args_keymap_s
}

function github_keymap_n {
	gp && gh pr create --fill && gh pr view --web
}

function github_keymap_o {
	git remote get-url origin | sed 's/.*[:/]\([^/]*\)\/.*/\1/'
}

function github_keymap_p {
	open https://"$(github_keymap_d)"/"$(github_keymap_o)"/"$(github_keymap_r)"/pull/"$1"
}

function github_keymap_r {
	git rev-parse --show-toplevel | xargs basename
}
