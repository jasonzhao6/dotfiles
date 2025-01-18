GITHUB_NAMESPACE='github_keymap'
GITHUB_ALIAS='h'
GITHUB_DOT="${GITHUB_ALIAS}${KEYMAP_DOT}"

GITHUB_KEYMAP=(
	"${GITHUB_DOT}e # Create a new PR, then open it"
	"${GITHUB_DOT}t # Create a new gist, then open it"
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

source "$ZSHRC_DIR/github_helpers.zsh"

function github_keymap_b {
	git rev-parse --abbrev-ref HEAD
}

function github_keymap_c {
	open https://"$(github_keymap_d)"/"$(github_keymap_o)"/"$(github_keymap_re)"/commit/"$1"
}

function github_keymap_d {
	github_keymap_url | sed 's/.*[:/]\([^/]*\)\/.*\/.*/\1/'
}

function github_keymap_e {
	gp && gh pr create --fill && gh pr view --web
}

function github_keymap_h {
	local repo=${*:-$(github_keymap_re 2> /dev/null)}

	local domain; domain="$(github_keymap_domain)"
	local org; org="$(github_keymap_org)"
	open https://"$domain"/"$org"/"$repo"
}

function github_keymap_n {
	local repo=$1

	# TODO Stop aliasing org when setting up next dev env
	org="${org//$GITHUB_SOURCE_ORG/$GITHUB_TARGET_ORG}"

	local org; org="$(github_keymap_org)"
	cd ~/gh/"$org"/"$repo" && nav_keymap_n || true
}

function github_keymap_o {
	github_keymap_url | sed 's/.*[:/]\([^/]*\)\/.*/\1/'
}

function github_keymap_p {
	open https://"$(github_keymap_d)"/"$(github_keymap_o)"/"$(github_keymap_re)"/pull/"$1"
}

function github_keymap_r {
	local filters=("$@")

	local org; org="$(github_keymap_org)"
	args_keymap_s "${filters[@]}" < ~/Documents/github.repos."$org".txt
}

function github_keymap_re {
	git rev-parse --show-toplevel | xargs basename
}

function github_keymap_s {
	# Save a copy for cached lookup
	local org; org="$(github_keymap_org)"
	gh repo list "$org" --no-archived --limit 1000 --json name |
		jq -r '.[].name' |
		tee ~/Documents/github.repos."$org".txt |
		args_keymap_s
}

function github_keymap_t {
	pbpaste | gh gist create --web
}
