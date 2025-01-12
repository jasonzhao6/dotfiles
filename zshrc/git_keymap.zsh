GIT_NAMESPACE='git_keymap'
GIT_ALIAS='g'

GIT_KEYMAP=(
	"$GIT_ALIAS${KEYMAP_DOT}g # Checkout the latest \`main\`"
	"$GIT_ALIAS${KEYMAP_DOT}b # List branches"
	"$GIT_ALIAS${KEYMAP_DOT}bb # Delete merged branches"
	"$GIT_ALIAS${KEYMAP_DOT}bd <name> # Delete a branch by name"
	"$GIT_ALIAS${KEYMAP_DOT}c <name> # Checkout a branch by name"
	"$GIT_ALIAS${KEYMAP_DOT}n <name> # Create a new branch by name"
	''
	"$GIT_ALIAS${KEYMAP_DOT}d # Git diff"
	"$GIT_ALIAS${KEYMAP_DOT}t # Git status"
	"$GIT_ALIAS${KEYMAP_DOT}j # Create a new commit"
	"$GIT_ALIAS${KEYMAP_DOT}e # Create an empty commit"
	"$GIT_ALIAS${KEYMAP_DOT}m # Amend the previous commit"
	"$GIT_ALIAS${KEYMAP_DOT}w # Reword the previous commit"
	"$GIT_ALIAS${KEYMAP_DOT}y # Cherry pick a commit"
	"$GIT_ALIAS${KEYMAP_DOT}i # Fix up a commit"
	''
	"$GIT_ALIAS${KEYMAP_DOT}x <number> # Rebase the last <number> commits"
	"$GIT_ALIAS${KEYMAP_DOT}x # Rebase with the latest main"
	"$GIT_ALIAS${KEYMAP_DOT}xm # Rebase with the latest master"
	"$GIT_ALIAS${KEYMAP_DOT}xu # Rebase with the latest upstream"
	"$GIT_ALIAS${KEYMAP_DOT}xc # Rebase continue"
	"$GIT_ALIAS${KEYMAP_DOT}xa # Rebase abort"
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
	''
	"$GIT_ALIAS${KEYMAP_DOT}r # List logs"
	"$GIT_ALIAS${KEYMAP_DOT}r <match>* # Filter logs"
	"$GIT_ALIAS${KEYMAP_DOT}rr # List first parent logs"
	"$GIT_ALIAS${KEYMAP_DOT}rr <match>* # Filter first parent logs"
	''
	"$GIT_ALIAS${KEYMAP_DOT}P # Pull"
	"$GIT_ALIAS${KEYMAP_DOT}p # Push"
	"$GIT_ALIAS${KEYMAP_DOT}f # Force push"
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

function git_keymap_d {
	git diff
}

function git_keymap_e {
	git commit --allow-empty -m 're-run: Empty commit to trigger build'
}

function git_keymap_f {
	git push --force
}

function git_keymap_g {
	git checkout main || git checkout master
	git pull
	git status
}

function git_keymap_i {
	local sha=$1

	git add --all; git commit --fixup "$sha"
}

function git_keymap_j {
	git add --all
	git commit
}

function git_keymap_l {
	git stash list --pretty=format:'%C(yellow)%gd %C(magenta)%as %C(green)%s'
}

function git_keymap_m {
	git add --all
	git commit --amend --no-edit
}

function git_keymap_n {
	git_keymap_m
	git checkout -b "$@"
}

function git_keymap_p {
	git push
}

function git_keymap_P {
	git pull
}

function git_keymap_r {
	local matches=$*

	local greps; greps="--grep='${matches// /' --grep='}'"
	local command; command="git log $GIT_KEYMAP_FIRST_PARENT ${matches:+--all} $greps"
	command+=" --all-match --extended-regexp --regexp-ignore-case"
	command+=" --pretty=format:\"%C(yellow)%h %C(magenta)%as %C(green)'%s' %C(cyan)%an\""

	eval "$command"
}

function git_keymap_rr {
	GIT_KEYMAP_FIRST_PARENT=--first-parent gr "$@"
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

function git_keymap_w {
	git add --all
	git commit --amend
}

# TODO split into multiple keys
function git_keymap_x {
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

function git_keymap_xa {
	git rebase --abort
}

function git_keymap_xc {
	git add --all
	git rebase --continue
}

function git_keymap_xm {
	git_keymap_r m
}

function git_keymap_xu {
	git_keymap_r u
}

function git_keymap_y {
	local sha=$1

	git cherry-pick "$sha"
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
