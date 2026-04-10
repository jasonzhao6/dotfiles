GITHUB_NAMESPACE='github_keymap'
GITHUB_ALIAS='h'
GITHUB_DOT="${GITHUB_ALIAS}${KEYMAP_DOT}"

GITHUB_KEYMAP=(
	"${GITHUB_DOT}h <match>* <-mismatch>* # Navigate to GitHub & list repos & filter"
	"${GITHUB_DOT}t # Navigate to the repo name in pasteboard"
	"${GITHUB_DOT}tt # Copy the current repo name to pasteboard"
	''
	"${GITHUB_DOT}a # Open the current repo in GitHub Desktop"
	"${GITHUB_DOT}n # Create a new PR, then open it"
	"${KEYMAP_PIPE_PATTERN}${GITHUB_DOT}g # Create a new gist, then open it"
	"${GITHUB_DOT}gg # Open new tab to create a gist"
	''
	"${GITHUB_ALIAS} <repo> # Open the specified repo"
	"${GITHUB_DOT}o # Open the current repo"
	"${GITHUB_DOT}p <pr>? # Open PRs (or a specific PR)"
	"${GITHUB_DOT}c <sha>? # Open a commit (Default: Pasteboard)"
	''
	"${GITHUB_DOT}r <match>* <-mismatch>* # List remote repos & filter"
	"${GITHUB_DOT}rr # Save a copy of remote repos"
	''
	"${GITHUB_DOT}url # Remote url"
	"${GITHUB_DOT}domain # Remote domain"
	"${GITHUB_DOT}org # Org name"
	"${GITHUB_DOT}repo # Repo name"
	"${GITHUB_DOT}branch # Branch name"
)

keymap_init $GITHUB_NAMESPACE $GITHUB_ALIAS "${GITHUB_KEYMAP[@]}"

function github_keymap {
	# If the first arg is a repo in the current org, delegate to `github_keymap_o`
	local repo=$1
	if grep --quiet "^$repo$" $ZSHRC_DATA_DIR/github/"$(github_keymap_org)".txt 2> /dev/null; then
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

	cd ~/GitHub && echo && ls -d */* | args_keymap_s "${filters[@]}"
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

GITHUB_ALL_REPOS="$ZSHRC_DATA_DIR/github.all.txt"

function github_keymap_r {
	local filters=("$@")

	args_keymap_s "${filters[@]}" < $GITHUB_ALL_REPOS
}

function github_keymap_repo {
	git rev-parse --show-toplevel | xargs basename
}

function github_keymap_rr {
	local orgs org hostname repos count=0
	orgs=(~/GitHub/*/)

	# Reset local cache
	rm -rf $ZSHRC_DATA_DIR/github
	mkdir -p $ZSHRC_DATA_DIR/github
	: > $GITHUB_ALL_REPOS

	# Iterate over each org and fetch its repos
	for org in "${orgs[@]}"; do
		org=$(basename "$org")
		((count++))
		echo -n "[${count}/${#orgs}] ${org}"

		# Infer hostname from the first cloned repo's remote url
		hostname=$(git -C ~/GitHub/"$org"/*(Y1) remote get-url origin 2> /dev/null |
			sed 's/.*[:/]\([^/]*\)\/.*\/.*/\1/')
		if [[ -z $hostname ]]; then echo ' ... skipped'; continue; fi

		# Avoid rate limiting, wait a second in between orgs
		sleep 1

		# Fetch repos and save to per-org and combined files
		repos=$(GH_HOST=$hostname gh repo list "$org" --no-archived --limit 1000 --json name 2> /dev/null |
			jq --raw-output '.[].name')
		if [[ -z $repos ]]; then echo ' ... skipped'; continue; fi
		echo "$repos" > $ZSHRC_DATA_DIR/github/"$org".txt
		echo "$repos" | sed "s|^|$org/|" >> $GITHUB_ALL_REPOS
		echo " ... $(echo "$repos" | wc -l | tr -d ' ') repos"
	done
}

function github_keymap_t {
	local repo; repo=$(paste_when_empty "$1")

	# If pasteboard is empty, error
	if [[ -z $repo ]]; then
		red_bar 'Empty repo name in pasteboard'
		return
	fi

	# Note: Do not use `local path`- It will overwrite $PATH in subshell
	local target_path; target_path=~/GitHub/$(github_keymap_org)/$repo

	# If it's not a folder path, error
	if [[ ! -d $target_path  ]]; then
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
