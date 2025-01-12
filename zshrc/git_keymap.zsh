GIT_NAMESPACE='git_keymap'
GIT_ALIAS='g'

GIT_KEYMAP=(
	"$GIT_ALIAS${KEYMAP_DOT}b # List branches"
	"$GIT_ALIAS${KEYMAP_DOT}bb # Delete merged branches"
	"$GIT_ALIAS${KEYMAP_DOT}bd <name> # Delete a branch by name"
	"$GIT_ALIAS${KEYMAP_DOT}c <name> # Checkout a branch by name"
	"$GIT_ALIAS${KEYMAP_DOT}m # Checkout the latest \`main\`"
	"$GIT_ALIAS${KEYMAP_DOT}n <name> # Create a new branch from the latest \`main\`"
	''
	"$GIT_ALIAS${KEYMAP_DOT}d # Git diff"
	"$GIT_ALIAS${KEYMAP_DOT}t # Git status"
	"$GIT_ALIAS${KEYMAP_DOT}cn # Create a new commit"
	"$GIT_ALIAS${KEYMAP_DOT}ca # Amend the previous commit"
	"$GIT_ALIAS${KEYMAP_DOT}cr # Reword the previous commit"
	"$GIT_ALIAS${KEYMAP_DOT}ce # Create an empty commit"
	"$GIT_ALIAS${KEYMAP_DOT}cp # Cherry pick a commit"
	"$GIT_ALIAS${KEYMAP_DOT}cf # Fix up a commit"
	''
	"$GIT_ALIAS${KEYMAP_DOT}r <number> # Rebase the last <number> commits"
	"$GIT_ALIAS${KEYMAP_DOT}r # Rebase with the latest main"
	"$GIT_ALIAS${KEYMAP_DOT}rm # Rebase with the latest master"
	"$GIT_ALIAS${KEYMAP_DOT}ru # Rebase with the latest upstream"
	"$GIT_ALIAS${KEYMAP_DOT}ra # Rebase abort"
	"$GIT_ALIAS${KEYMAP_DOT}rc # Rebase continue"
	''
	"$GIT_ALIAS${KEYMAP_DOT}u # Undo the last commit"
	"$GIT_ALIAS${KEYMAP_DOT}u <number> # Undo the last <number> commits"
	"$GIT_ALIAS${KEYMAP_DOT}z # Discard uncommitted changes"
	"$GIT_ALIAS${KEYMAP_DOT}z <number> # Discard uncommitted changes & the last <number> commits"
	''
	"$GIT_ALIAS${KEYMAP_DOT}s # Git stash"
	"$GIT_ALIAS${KEYMAP_DOT}s <message> # Git stash with message"
	"$GIT_ALIAS${KEYMAP_DOT}a # Git apply the last stash"
	"$GIT_ALIAS${KEYMAP_DOT}a <index> # Git apply stash by index"
	"$GIT_ALIAS${KEYMAP_DOT}l # Git stash list"
	"$GIT_ALIAS${KEYMAP_DOT}sc # Git stash clear"
)

keymap_init $GIT_NAMESPACE $GIT_ALIAS "${GIT_KEYMAP[@]}"

function git_keymap {
	keymap_invoke $GIT_NAMESPACE $GIT_ALIAS ${#GIT_KEYMAP} "${GIT_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

export EDITOR='mate --wait'

function git_keymap_a {
	local index=${1:-0}

	git stash apply "stash@{$index}"
}

function git_keymap_b {
	local branches; branches=$(git branch)
	local merged; merged=$(git_merged)

	if [[ -n $merged ]]; then
		branches+="\n----------------\n$merged"
	fi

	echo "$branches" | args_keymap_s
}

function git_keymap_bb {
	git_merged | xargs git branch --delete
	git remote prune origin
	echo
	git_keymap_b
}

function git_keymap_bd {
	local name=$1

	git branch --delete --force "$name"
	git push origin --delete "$name"
	git_keymap_b
}

function git_keymap_c {
	local name=$1;

	git checkout "$name"
}

function git_keymap_ca {
	git add --all
	git commit --amend --no-edit
}

function git_keymap_ce {
	git commit --allow-empty -m 're-run: Empty commit to trigger build'
}

function git_keymap_cf {
	local sha=$1

	git add --all; git commit --fixup "$sha"
}

function git_keymap_cn {
	git add --all
	git commit
}

function git_keymap_cp {
	local sha=$1

	git cherry-pick "$sha"
}

function git_keymap_cr {
	git add --all
	git commit --amend
}

function git_keymap_d {
	git diff
}

function git_keymap_l {
	git stash list --pretty=format:'%C(yellow)%gd %C(magenta)%as %C(green)%s'
}

function git_keymap_m {
	git checkout main || git checkout master
	git pull
	git status
}

function git_keymap_n {
	git_keymap_m
	git checkout -b "$@"
}

# TODO split into multiple keys
function git_keymap_r {
	local gxx_remote; gxx_remote=origin
	local gxx_branch; gxx_branch=main
	local gxx_head_num

	for var in "$@"; do
		case $var in
			u) gxx_remote=upstream;;
			m) gxx_branch=master;;
			*) gxx_head_num=$var;;
		esac
	done

	if [[ -n $gxx_head_num ]]; then
		# The `+ 1` is to count the `fixup!` commit itself
		git rebase --interactive --autosquash HEAD~$((gxx_head_num + 1))
	else
		git fetch "$gxx_remote" "$gxx_branch" && git rebase --interactive --autosquash "$gxx_remote/$gxx_branch"
	fi
}

function git_keymap_ra {
	git rebase --abort
}

function git_keymap_rc {
	git add --all
	git rebase --continue
}

function git_keymap_rm {
	git_keymap_r m
}

function git_keymap_ru {
	git_keymap_r u
}

function git_keymap_s {
	local message="$*"

	git add --all
	git stash save "$message"
}

function git_keymap_sc {
	git stash clear
}

function git_keymap_t {
	git status
}

function git_keymap_u {
	local number=$1

	git reset --soft HEAD~"$number"
}

function git_keymap_z {
	local number=$1

	if [[ -n $number ]]; then
		git_keymap_u "$number"
	fi

	git add --all
	git reset --hard
	git status
}
