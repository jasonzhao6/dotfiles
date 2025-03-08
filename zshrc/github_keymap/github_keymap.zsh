GITHUB_NAMESPACE='github_keymap'
GITHUB_ALIAS='h'
GITHUB_DOT="${GITHUB_ALIAS}${KEYMAP_DOT}"

GITHUB_KEYMAP=(
	"${GITHUB_DOT}n # Create a new PR, then open it"
	"${GITHUB_DOT}g # Create a new gist, then open it"
	''
	"${GITHUB_DOT}s # Save a copy of repos"
	"${GITHUB_DOT}r # List repos"
	"${GITHUB_DOT}r {match}* {-mismatch}* # Filter repos"
	''
	"${GITHUB_DOT}h # Navigate to the current org"
	"${GITHUB_DOT}h {match}* {-mismatch}* # Navigate to the current org & filter repos"
	"${GITHUB_DOT}o # Open the current repo"
	"${GITHUB_DOT}o {repo} # Open the specified repo (Shortcut: \`$GITHUB_ALIAS\`)"
	"${GITHUB_DOT}p # Open the latest PRs"
	"${GITHUB_DOT}p {pr} # Open the specified PR"
	"${GITHUB_DOT}c # Open the latest commit"
	"${GITHUB_DOT}c {sha} # Open the specified commit"
	''
	"${GITHUB_DOT}d # Domain name"
	"${GITHUB_DOT}oo # Org name"
	"${GITHUB_DOT}rr # Repo name"
	"${GITHUB_DOT}b # Branch name"
)

keymap_init $GITHUB_NAMESPACE $GITHUB_ALIAS "${GITHUB_KEYMAP[@]}"

function github_keymap {
	# If the first arg is a repo in the current org, delegate to `github_keymap_h`
	local repo=$1
	if grep --quiet "^$repo$" ~/Documents/github.repos."$(github_keymap_org)".txt; then
		github_keymap_o "$repo"
		return
	fi

	keymap_show $GITHUB_NAMESPACE $GITHUB_ALIAS ${#GITHUB_KEYMAP} "${GITHUB_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/$GITHUB_NAMESPACE/github_helpers.zsh"

function github_keymap_b {
	git rev-parse --abbrev-ref HEAD
}

function github_keymap_c {
	open https://"$(github_keymap_domain)"/"$(github_keymap_org)"/"$(github_keymap_rr)"/commit/"$1"
}

function github_keymap_d {
	github_keymap_url | sed 's/.*[:/]\([^/]*\)\/.*\/.*/\1/'
}

function github_keymap_g {
	# When invoked as standalone command
	if [[ -t 0 ]]; then
		pbpaste | gh gist create --web

	# When invoked after a pipe `|`
	else
		gh gist create --web
	fi
}

function github_keymap_h {
	local filters=("$@")

	cd ~/github/"$(github_keymap_org)" && nav_keymap_n "${filters[@]}"
}

function github_keymap_n {
	gp && gh pr create --fill && gh pr view --web
}

function github_keymap_o {
	local repo=${*:-$(github_keymap_rr 2> /dev/null)}

	open https://"$(github_keymap_domain)"/"$(github_keymap_org)"/"$repo"
}

function github_keymap_oo {
	github_keymap_url | sed 's/.*[:/]\([^/]*\)\/.*/\1/'
}

function github_keymap_p {
	open https://"$(github_keymap_domain)"/"$(github_keymap_org)"/"$(github_keymap_rr)"/pull/"$1"
}

function github_keymap_r {
	local filters=("$@")

	args_keymap_s "${filters[@]}" < ~/Documents/github.repos."$(github_keymap_org)".txt
}

function github_keymap_rr {
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
