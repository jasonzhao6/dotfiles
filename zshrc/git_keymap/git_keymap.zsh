GIT_NAMESPACE='git_keymap'
GIT_ALIAS='g'
GIT_DOT="${GIT_ALIAS}${KEYMAP_DOT}"

GIT_KEYMAP=(
	"${GIT_ALIAS} <branch> # Checkout branch"
	"${GIT_DOT}g # Checkout latest \`main\`"
	"${GIT_DOT}n <branch> # Checkout latest \`main\` & create branch"
	''
	"${GIT_DOT}b # List local branches"
	"${GIT_DOT}bb # Delete merged branches"
	"${GIT_DOT}bd <branch> # Delete specified branch"
	''
	"${GIT_DOT}i # Status"
	"${GIT_DOT}d # Diff"
	"${GIT_DOT}s <message>? # Stash"
	"${GIT_DOT}a <index>? # Apply a stash (Default: Latest)"
	"${GIT_DOT}l # List stashes"
	"${GIT_DOT}lc # Clear stashes"
	''
	"${GIT_DOT}w # Write a new commit"
	"${GIT_DOT}ww # Write a new commit, allow empty"
	"${GIT_DOT}m # Amend previous commit, no edit"
	"${GIT_DOT}mm # Amend previous commit"
	''
	"${GIT_DOT}u <number>? # Undo last N commits (Default: 1)"
	"${GIT_DOT}z <number>? # Discard changes & N commits (Default: 0)"
	"${GIT_DOT}zz # Discard changes & 1 commit"
	''
	"${GIT_DOT}e # List last 20 commits"
	"${GIT_DOT}e <sha> # Create fixup commit"
	"${GIT_DOT}ee (<N>,u,m)? # Rebase (Default: origin/main)"
	"${GIT_DOT}ec # Rebase continue"
	"${GIT_DOT}ea # Rebase abort"
	''
	"${GIT_DOT}c <sha>? # Cherry pick (Default: Pasteboard)"
	"${GIT_DOT}cc # Cherry pick continue"
	"${GIT_DOT}ca # Cherry pick abort"
	''
	"${GIT_DOT}t <sha>? # Revert commit (Default: Pasteboard)"
	"${GIT_DOT}tc # Revert continue"
	"${GIT_DOT}ta # Revert abort"
	''
	"${GIT_DOT}pp # Pull"
	"${GIT_DOT}p # Push"
	"${GIT_DOT}f # Force push with lease"
	"${GIT_DOT}ff # Force push"
	''
	"${GIT_DOT}r <match>* # List commits & filter"
	"${GIT_DOT}rr <match>* # List first-parent commits & filter"
	''
	"${GIT_DOT}h # (Reserved: GitHub CLI)"
	"${GIT_DOT}o # (Reserved: Go language)"
)

keymap_init $GIT_NAMESPACE $GIT_ALIAS "${GIT_KEYMAP[@]}"

function git_keymap {
	local branch=$1

	# If arg is a branch in a git repo, check it out
	if [[ -n $branch ]] && git status > /dev/null 2>&1; then
	  # If single-branch clone, fix to allow fetching all branches
  	if [[ $(git config --get remote.origin.fetch) != *'*'* ]]; then
			git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
		fi

		# Fetch the specific branch and checkout
		if git fetch origin "$branch" 2> /dev/null; then
			if git checkout "$branch" 2> /dev/null; then
				return
			fi
		fi
	fi

	keymap_show $GIT_NAMESPACE $GIT_ALIAS ${#GIT_KEYMAP} "${GIT_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

# Sources
source "$ZSHRC_SRC_DIR/$GIT_NAMESPACE/git_helpers.zsh"

# Constants
export EDITOR='mate --wait'

function git_keymap_a {
	local index=${1:-0}

	git stash apply "stash@{$index}"
}

function git_keymap_b {
	local branches; branches=$(git branch)
	local merged; merged=$(git_helpers_merged)

	if [[ -n $merged ]]; then
		branches+="\n$(dashes)\n$merged"
	fi

	echo "$branches" | args_keymap_s
}

function git_keymap_bb {
	git_helpers_merged | xargs -I {} zsh -c 'git branch --delete {}; git push --delete origin {}'

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
	local sha; sha=$(paste_when_empty "$1")

	git cherry-pick "$sha"
}

function git_keymap_ca {
	git cherry-pick --abort
}

function git_keymap_cc {
	git add --all
	git cherry-pick --continue
}

function git_keymap_d {
	git add --all
	git diff --staged
}

function git_keymap_e {
	local sha=$1

	if [[ -z $sha ]]; then
		gr | head -20 | args_keymap_so
	else
		git add --all
		git commit --fixup "$sha"
	fi
}

function git_keymap_ea {
	git rebase --abort
}

function git_keymap_ec {
	git add --all
	git rebase --continue
}

function git_keymap_ee {
	local options=$1

	local remote; remote=origin
	local branch; branch=main
	local head_num

	# Rule: OR (AND/OR u m) *
	for var in $options; do
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

function git_keymap_f {
	git push --force-with-lease
}

function git_keymap_ff {
	git push --force
}

function git_keymap_g {
	if ! git diff --quiet || ! git diff --cached --quiet; then
		red_bar 'Uncommitted changes'
		return 1
	fi

	git checkout main 2> /dev/null || git checkout master
	git pull
	git status
}

function git_keymap_i {
	git status
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

function git_keymap_mm {
	git add --all
	git commit --amend
}

function git_keymap_n {
	git_keymap_g || return
	git checkout -b "$@"
}

function git_keymap_p {
	git push
}

function git_keymap_pp {
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
	local message=$*

	git add --all
	git stash save "$message"
}

function git_keymap_t {
	local sha; sha=$(paste_when_empty "$1")

	git revert "$sha"
}

function git_keymap_ta {
	git revert --abort
}

function git_keymap_tc {
	git add --all
	git revert --continue
}

function git_keymap_u {
	local number=$1

	git reset --soft HEAD~"$number"
}

function git_keymap_w {
	git add --all
	git commit
}

function git_keymap_ww {
	git commit --allow-empty -m 're-run: Empty commit to trigger build'
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

function git_keymap_zz {
	git_keymap_z 1
}
