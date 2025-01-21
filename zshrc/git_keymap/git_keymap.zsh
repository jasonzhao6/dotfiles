GIT_NAMESPACE='git_keymap'
GIT_ALIAS='g'
GIT_DOT="${GIT_ALIAS}${KEYMAP_DOT}"

GIT_KEYMAP=(
	"${GIT_DOT}c <branch> # Checkout an existing branch (Shortcut: \`$GIT_ALIAS\`)"
	"${GIT_DOT}n <branch> # Checkout a new branch"
	"${GIT_DOT}g # Checkout the latest \`main\`"
	"${GIT_DOT}b # List branches"
	"${GIT_DOT}bb # Delete merged branches"
	"${GIT_DOT}bd <branch> # Delete the specified branch"
	''
	"${GIT_DOT}d # Git diff"
	"${GIT_DOT}t # Git status"
	"${GIT_DOT}e # Create a new commit"
	"${GIT_DOT}m # Amend the previous commit"
	"${GIT_DOT}w # Reword the previous commit"
	"${GIT_DOT}v # Create an empty commit"
	"${GIT_DOT}y # Cherry pick a commit"
	"${GIT_DOT}i # Fix up a commit"
	"${GIT_DOT}ii # List the last 20 commits"
	''
	"${GIT_DOT}x <number> # Rebase the last N commits"
	"${GIT_DOT}x # Rebase with the latest main"
	"${GIT_DOT}xm # Rebase with the latest master"
	"${GIT_DOT}xu # Rebase with the latest upstream"
	"${GIT_DOT}xc # Rebase continue"
	"${GIT_DOT}xa # Rebase abort"
	''
	"${GIT_DOT}u # Undo the last commit"
	"${GIT_DOT}u <number> # Undo the last N commits"
	"${GIT_DOT}z # Discard uncommitted changes"
	"${GIT_DOT}z <number> # Discard uncommitted changes & the last N commits"
	''
	"${GIT_DOT}s # Git stash"
	"${GIT_DOT}s <message> # Git stash with message"
	"${GIT_DOT}a # Apply the last stash"
	"${GIT_DOT}a <index> # Apply stash by index"
	"${GIT_DOT}l # List the stash"
	"${GIT_DOT}lc # Clear the stash"
	''
	"${GIT_DOT}r # List logs"
	"${GIT_DOT}r <match>* # Filter logs"
	"${GIT_DOT}rr # List first parent logs"
	"${GIT_DOT}rr <match>* # Filter first parent logs"
	''
	"${GIT_DOT}P # Pull"
	"${GIT_DOT}p # Push"
	"${GIT_DOT}f # Force push"
)

keymap_init $GIT_NAMESPACE $GIT_ALIAS "${GIT_KEYMAP[@]}"

function git_keymap {
	# If the first arg is a branch in the current repo, delegate to `git_keymap_c`
	local branch=$1
	if egrep --quiet "^(\*| ) $branch$" <(git branch); then
		git_keymap_c "$branch"
		return
	fi

	keymap_invoke $GIT_NAMESPACE $GIT_ALIAS ${#GIT_KEYMAP} "${GIT_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

export EDITOR='mate --wait'

source "$ZSHRC_DIR/$GIT_NAMESPACE/git_helpers.zsh"

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
	git_merged | xargs -I {} zsh -c 'git branch --delete {}; git push --delete origin {}'

	echo
	git_keymap_b
}

function git_keymap_bd {
	local branch=$1

	git branch --delete --force "$branch"
	git push --delete origin "$branch"

	echo
	git_keymap_b
}

function git_keymap_c {
	local branch=$1;

	git checkout "$branch"
}

function git_keymap_d {
	git diff
}

function git_keymap_e {
	git add --all
	git commit
}

function git_keymap_f {
	git push --force
}

function git_keymap_g {
	git checkout main 2> /dev/null || git checkout master
	git pull
	git status
}

function git_keymap_i {
	local sha=$1

	git add --all; git commit --fixup "$sha"
}

function git_keymap_ii {
	gr | head -20 | args_keymap_so
}

function git_keymap_l {
	git stash list --pretty=format:'%C(yellow)%gd %C(magenta)%as %C(green)%s'
}

function git_keymap_lc {
	git stash clear
}

function git_keymap_m {
	git add --all
	git commit --amend --no-edit
}

function git_keymap_n {
	git_keymap_g
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

function git_keymap_t {
	git status
}

function git_keymap_u {
	local number=$1

	git reset --soft HEAD~"$number"
}

function git_keymap_v {
	git commit --allow-empty -m 're-run: Empty commit to trigger build'
}

function git_keymap_w {
	git add --all
	git commit --amend
}

function git_keymap_x {
	local option=$1

	local remote; remote=origin
	local branch; branch=main
	local head_num

	for var in $option; do
		case $var in
			u) remote=upstream;;
			m) branch=master;;
			*) head_num=$var;;
		esac
	done

	if [[ -n $head_num ]]; then
		# The `+ 1` is to count the `fixup!` commit itself
		git rebase --interactive --autosquash HEAD~$((head_num + 1))
	else
		git fetch "$remote" "$branch" && git rebase --interactive --autosquash "$remote/$branch"
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
	git_keymap_x m
}

function git_keymap_xu {
	git_keymap_x u
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
