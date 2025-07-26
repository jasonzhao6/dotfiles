GITHUB_NAMESPACE='github_keymap'
GITHUB_ALIAS='h'
GITHUB_DOT="${GITHUB_ALIAS}${KEYMAP_DOT}"

GITHUB_KEYMAP=(
	"${GITHUB_ALIAS} {repo} # Open the specified repo"
	"${GITHUB_DOT}o # Open the current repo"
	"${GITHUB_DOT}p # Open the latest PRs"
	"${GITHUB_DOT}p {pr} # Open the specified PR"
	"${GITHUB_DOT}c # Open the specified commit in pasteboard"
	"${GITHUB_DOT}c {sha} # Open the specified commit"
	''
	"${GITHUB_DOT}h # Navigate to the current org"
	"${GITHUB_DOT}h {match}* {-mismatch}* # Navigate to the current org & filter repos"
	"${GITHUB_DOT}t # Navigate to the repo name in pasteboard"
	"${GITHUB_DOT}tt # Save the current repo name to pasteboard"
	''
	"${GITHUB_DOT}a # Open the current repo in GitHub Desktop"
	"${GITHUB_DOT}n # Create a new PR, then open it"
	"${GITHUB_DOT}g {|}? # Create a new gist, then open it"
	"${GITHUB_DOT}gg # Open new tab to create a gist"
	''
	"${GITHUB_DOT}r # List remote repos"
	"${GITHUB_DOT}r {match}* {-mismatch}* # Filter remote repos"
	"${GITHUB_DOT}rr # Save a copy of remote repos"
	''
	"${GITHUB_DOT}url # Git url"
	"${GITHUB_DOT}domain # Domain name"
	"${GITHUB_DOT}org # Org name"
	"${GITHUB_DOT}repo # Repo name"
	"${GITHUB_DOT}branch # Branch name"
)

keymap_init $GITHUB_NAMESPACE $GITHUB_ALIAS "${GITHUB_KEYMAP[@]}"

function github_keymap {
	# If the first arg is a repo in the current org, delegate to `github_keymap_o`
	local repo=$1
	if grep --quiet "^$repo$" ~/Documents/zshrc-data/github."$(github_keymap_org)".txt; then
		github_keymap_o "$repo"
		return
	fi

	keymap_show $GITHUB_NAMESPACE $GITHUB_ALIAS ${#GITHUB_KEYMAP} "${GITHUB_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function github_keymap_a {
	open -a "GitHub Desktop" .
}

function github_keymap_branch {
	git rev-parse --abbrev-ref HEAD
}

function github_keymap_c {
	local sha; sha=$(paste_when_empty "$1")

	open https://"$(github_keymap_domain)"/"$(github_keymap_org)"/"$(github_keymap_repo)"/commit/"$sha"
}

GITHUB_DEFAULT_DOMAIN='github.marqeta.com'
function github_keymap_domain {
	local domain
	domain="$(github_keymap_url 2> /dev/null | sed 's/.*[:/]\([^/]*\)\/.*\/.*/\1/')"
	domain="${domain:-$GITHUB_DEFAULT_DOMAIN}"

	echo "$domain"
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

function github_keymap_gg {
	open https://"$(github_keymap_domain)"/gist
}

function github_keymap_h {
	local filters=("$@")

	cd ~/GitHub/"$(github_keymap_org)" && nav_keymap_n "${filters[@]}"
}

function github_keymap_n {
	gp && gh pr create --fill && gh pr view --web
}

function github_keymap_o {
	local repo=${*:-$(github_keymap_repo 2> /dev/null)}

	open https://"$(github_keymap_domain)"/"$(github_keymap_org)"/"$repo"
}

GITHUB_DEFAULT_ORG='transaction-engine'
function github_keymap_org {
	local org
	org="$(github_keymap_url 2> /dev/null | sed 's/.*[:/]\([^/]*\)\/.*/\1/')"
	org="${org:-$GITHUB_DEFAULT_ORG}"

	echo "$org"
}

function github_keymap_p {
	open https://"$(github_keymap_domain)"/"$(github_keymap_org)"/"$(github_keymap_repo)"/pull/"$1"
}

function github_keymap_r {
	local filters=("$@")

	args_keymap_s "${filters[@]}" < ~/Documents/zshrc-data/github."$(github_keymap_org)".txt
}

function github_keymap_repo {
	git rev-parse --show-toplevel | xargs basename
}

function github_keymap_rr {
	# Save a copy for cached lookup
	local org; org="$(github_keymap_org)"
	gh repo list "$org" --no-archived --limit 1000 --json name |
		jq --raw-output '.[].name' |
		tee ~/Documents/zshrc-data/github."$org".txt |
		args_keymap_s
}

function github_keymap_t {
	local repo; repo=$(paste_when_empty "$1")

	# If pasteboard is empty, error
	if [[ -z $repo ]]; then
		echo
		red_bar 'Empty repo name in pasteboard'
		return
	fi

	# Note: Do not use `local path`- It will overwrite $PATH in subshell
	local target_path; target_path=~/GitHub/$(github_keymap_org)/$repo

	# If it's not a folder path, error
	if [[ ! -d $target_path  ]]; then
		echo
		red_bar 'Invalid repo name in pasteboard'
		return
	fi

	cd "$target_path" && nav_keymap_n
}

function github_keymap_tt {
	github_keymap_repo | pbcopy
}

function github_keymap_url {
	# In case the current repo was forked, prefer the upstream url
	git remote get-url upstream 2> /dev/null || git remote get-url origin
}
