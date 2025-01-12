GIT_NAMESPACE='github_keymap'
GIT_ALIAS='h'

GIT_KEYMAP=(
	"$GIT_ALIAS·b # List branches"
	"$GIT_ALIAS·bb # Delete merged branches"
	"$GIT_ALIAS·bd <name> # Delete a branch by name"
	"$GIT_ALIAS·c <name> # Checkout a branch by name"
	"$GIT_ALIAS·m # Checkout the latest \`main\`"
	"$GIT_ALIAS·n <name> # Create a new branch from the latest \`main\`"
	''
	"$GIT_ALIAS·d # Diff"
	"$GIT_ALIAS·cn # Create a new commit"
	"$GIT_ALIAS·ca # Amend the previous commit"
	"$GIT_ALIAS·cr # Reword the previous commit"
	"$GIT_ALIAS·ce # Create an empty commit"
	"$GIT_ALIAS·cp # Cherry pick a commit"
	"$GIT_ALIAS·cf # Fix up a commit"
	''
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
) # TODO find new key than `n` for git info

keymap_init $GIT_NAMESPACE $GIT_ALIAS "${GIT_KEYMAP[@]}"

function github_keymap {
	keymap_invoke $GIT_NAMESPACE $GIT_ALIAS ${#GIT_KEYMAP} "${GIT_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

export EDITOR='mate --wait'

function github_keymap_b {
	local branches; branches=$(git branch)
	local merged; merged=$(gb_merged)

	if [[ -n $merged ]]; then
		branches+="\n----------------\n$merged"
	fi

	echo "$branches" | args_keymap_s
}

function github_keymap_bb {
	gb_merged | xargs git branch --delete
	git remote prune origin
	echo
	github_keymap_b
}

function github_keymap_bd {
	local name=$1

	git branch --delete --force "$name"
	git push origin --delete "$name"
	github_keymap_b
}

function github_keymap_c {
	local name=$1;

	git checkout "$name"
}

function github_keymap_ca {
	git add --all
	git commit --amend --no-edit
}

function github_keymap_ce {
	git commit --allow-empty -m 're-run: Empty commit to trigger build'
}

function github_keymap_cf {
	local sha=$1

	git add --all; git commit --fixup "$sha"
}

function github_keymap_cn {
	git add --all
	git commit
}

function github_keymap_cp {
	local sha=$1

	git cherry-pick "$sha"
}

function github_keymap_cr {
	git add --all
	git commit --amend
}

function github_keymap_d {
	git diff
}

function github_keymap_m {
	git checkout main || git checkout master
	git pull
	git status
}

function github_keymap_n {
	github_keymap_m
	git checkout -b "$@"
}

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
