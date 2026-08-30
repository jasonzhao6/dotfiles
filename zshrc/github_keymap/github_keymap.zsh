GITHUB_NAMESPACE='github_keymap'
GITHUB_ALIAS='h'
GITHUB_DOT="${GITHUB_ALIAS}${KEYMAP_DOT}"

GITHUB_KEYMAP=(
	"${GITHUB_DOT}h <match>* <-mismatch>* # List ~/GitHub, \`cd\` when only one match"
	"${GITHUB_DOT}r <match>* <-mismatch>* # List remote repos & filter"
	"${GITHUB_DOT}rr # Save copy of remote repos"
	''
	"${GITHUB_DOT}a <repo>? # Open GitHub app (Default: Current repo)"
	"${GITHUB_DOT}n # Open tab to new PR"
	"${GITHUB_DOT}g ${KEYMAP_PIPE_PATTERN} # Open tab to new gist"
	"${GITHUB_DOT}gg # Open tab to create gist"
	''
	"${GITHUB_DOT}o <path>? # Open tab to path at SHA (Default: CWD)"
	"${GITHUB_DOT}oo <path>? # Open tab to path at main (Default: CWD)"
	"${GITHUB_DOT}b # Open tab to branches"
	"${GITHUB_DOT}p <pr>? # Open tab to PRs (or a specific PR)"
	"${GITHUB_DOT}c <sha>? # Open tab to commit (Default: Pasteboard)"
	''
	"${GITHUB_DOT}url # Remote url"
	"${GITHUB_DOT}domain # Remote domain"
	"${GITHUB_DOT}org # Org name"
	"${GITHUB_DOT}repo # Repo name"
	"${GITHUB_DOT}branch # Branch name"
)

keymap_init $GITHUB_NAMESPACE $GITHUB_ALIAS "${GITHUB_KEYMAP[@]}"

function github_keymap {
	keymap_show $GITHUB_NAMESPACE $GITHUB_ALIAS ${#GITHUB_KEYMAP} "${GITHUB_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

# Sources
source "$ZSHRC_SRC_DIR/$GITHUB_NAMESPACE/github_helpers.zsh"

# Constants
GITHUB_DEFAULT_DOMAIN='github.marqeta.com'
GITHUB_DEFAULT_ORG='transaction-engine'
GITHUB_ALL_REPOS="$ZSHRC_DATA_DIR/github.all.txt"
GITHUB_MD_REGEX='^#{1,6} |^\*\*|^- |^```|^\[.+\]\(.+\)' # headings, bold, lists, code fences, links

function github_keymap_a {
	local target_path=${1:-.}

	# If target looks like org/repo and isn't cloned yet, clone it first
	if [[ $target_path == */* && ! -d $target_path && ! -d ~/GitHub/$target_path ]]; then
		gh repo clone "$target_path" ~/GitHub/"$target_path" || return
		cd ~/GitHub/"$target_path" || return
	fi

	# Resolve org/repo to ~/GitHub path
	[[ $target_path == */* && ! -d $target_path ]] && target_path=~/GitHub/$target_path

	open -a "GitHub Desktop" "$target_path"
}

# shellcheck disable=SC2120 # `target_path` is an optional arg
function github_keymap_b {
	local target_path=$*

	# When the arg is a path to a repo, read its remote instead of the current one
	if github_helpers_is_repo_root "$target_path"; then
		( cd "$target_path" && github_keymap_b )
		return
	fi

	open "$(github_keymap_url)/branches"
}

function github_keymap_branch {
	git rev-parse --abbrev-ref HEAD 2> /dev/null
}

function github_keymap_c {
	local sha; sha=$(paste_when_empty "$1")

	open "$(github_keymap_url)/commit/$sha"
}

function github_keymap_domain {
	local domain
	domain="$(github_keymap_url | sed 's|https://\([^/]*\)/.*|\1|')"
	domain="${domain:-$GITHUB_DEFAULT_DOMAIN}"

	echo "$domain"
}

function github_keymap_g {
	local content

	# When invoked as standalone command
	if [[ -t 0 ]]; then
		content=$(pbpaste)

	# When invoked after a pipe `|`
	else
		content=$(cat)
	fi

	local ext='txt'
	if echo "$content" | grep -qE "$GITHUB_MD_REGEX"; then
		ext='md'
	elif github_helpers_is_delimited $'\t' "$content"; then
		ext='tsv'
	elif github_helpers_is_delimited ',' "$content"; then
		ext='csv'
	fi

	echo "$content" | gh gist create --filename "gist.$ext" --web
}

function github_keymap_gg {
	open https://"$(github_keymap_domain)"/gist
}

function github_keymap_h {
	local filters=("$@")

	cd ~/GitHub || return

	ls -d -- */* | args_keymap_s "${filters[@]}"

	nav_helpers_cd_if_only_match
}

function github_keymap_n {
	gp && gh pr create --fill && gh pr view --web
}

function github_keymap_o {
	local target_path=${1:-.}

	# If target looks like org/repo and isn't a local path, open remote URL
	if [[ $target_path == */* && ! -d $target_path ]]; then
		open "https://$(github_keymap_domain)/$target_path"
		return
	fi

	# Get repo root and current SHA
	local repo_root sha rel_path url
	repo_root=$(git rev-parse --show-toplevel 2> /dev/null) || return
	sha=$(git rev-parse HEAD 2> /dev/null) || return

	# Warn if HEAD hasn't been pushed
	if ! git branch -r --contains "$sha" 2> /dev/null | grep -q .; then
		red_bar "Commit $sha not pushed yet"
		return 1
	fi

	# Get path relative to repo root
	if [[ -d $target_path ]]; then
		rel_path=$(cd "$target_path" && pwd | sed "s|^$repo_root||")
	else
		rel_path=$(cd "$(dirname "$target_path")" && pwd | sed "s|^$repo_root||")
		rel_path="$rel_path/$(basename "$target_path")"
	fi

	# Build URL: repo/tree/sha/path for dirs, repo/blob/sha/path for files
	if [[ -d $target_path ]]; then
		url="$(github_keymap_url)/tree/$sha$rel_path"
	else
		url="$(github_keymap_url)/blob/$sha$rel_path"
	fi

	if [[ -z $ZSHRC_UNDER_TESTING ]]; then
		open "$url"
	else
		echo "$url"
	fi
}

function github_keymap_oo {
	local target_path=${1:-.}
	local ref=${2:-main}

	# Get repo root
	local repo_root rel_path url
	repo_root=$(git rev-parse --show-toplevel 2> /dev/null) || return

	# Get path relative to repo root
	if [[ -d $target_path ]]; then
		rel_path=$(cd "$target_path" && pwd | sed "s|^$repo_root||")
	else
		rel_path=$(cd "$(dirname "$target_path")" && pwd | sed "s|^$repo_root||")
		rel_path="$rel_path/$(basename "$target_path")"
	fi

	# Build URL: repo/tree/ref/path for dirs, repo/blob/ref/path for files
	if [[ -d $target_path ]]; then
		url="$(github_keymap_url)/tree/$ref$rel_path"
	else
		url="$(github_keymap_url)/blob/$ref$rel_path"
	fi

	if [[ -z $ZSHRC_UNDER_TESTING ]]; then
		open "$url"
	else
		echo "$url"
	fi
}

function github_keymap_org {
	local org
	org="$(github_keymap_url | sed 's|https://[^/]*/\([^/]*\)/.*|\1|')"
	org="${org:-$GITHUB_DEFAULT_ORG}"

	echo "$org"
}

function github_keymap_p {
	open "$(github_keymap_url)/pull/$1"
}

function github_keymap_r {
	local filters=("$@")

	cd ~/GitHub || return

	args_keymap_s "${filters[@]}" < "$GITHUB_ALL_REPOS"
}

function github_keymap_repo {
	git rev-parse --show-toplevel 2> /dev/null | xargs basename
}

function github_keymap_rr {
	local orgs org hostname repos count=0
	orgs=(~/GitHub/*/)

	# Accumulate in a temp file, so an interrupted run leaves the existing cache intact
	# Note: Keep it beside the cache, so the final `mv` is an atomic same-filesystem rename
	local temp_file="$GITHUB_ALL_REPOS.tmp"
	: > "$temp_file"

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

		# Fetch repos and save to the combined file
		repos=$(GH_HOST=$hostname gh repo list "$org" --no-archived --limit 1000 --json name 2> /dev/null |
			jq --raw-output '.[].name')
		if [[ -z $repos ]]; then echo ' ... skipped'; continue; fi
		# shellcheck disable=SC2001 # More readable as sed than parameter expansion
		echo "$repos" | sed "s|^|$org/|" >> "$temp_file"
		echo " ... $(echo "$repos" | wc -l | tr -d ' ') repos"
	done

	# Keep the existing cache when a run fetches nothing, e.g. offline or `gh` not authed
	if [[ ! -s $temp_file ]]; then
		rm -f "$temp_file"
		red_bar 'Fetched no repos, keeping existing cache'
		return 1
	fi

	mv "$temp_file" "$GITHUB_ALL_REPOS"
}

function github_keymap_url {
	# Prefer upstream for forks
	(git remote get-url upstream 2> /dev/null || git remote get-url origin 2> /dev/null) | sed 's/\.git$//'
}
