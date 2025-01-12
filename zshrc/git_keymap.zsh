GIT_NAMESPACE='git_keymap'
GIT_ALIAS='g'

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
	"$GIT_ALIAS·r <number> # Rebase the last <number> commits"
	"$GIT_ALIAS·r # Rebase with the latest main"
	"$GIT_ALIAS·rm # Rebase with the latest master"
	"$GIT_ALIAS·ru # Rebase with the latest upstream"
	"$GIT_ALIAS·ra # Rebase abort"
	"$GIT_ALIAS·rc # Rebase continue"
)

keymap_init $GIT_NAMESPACE $GIT_ALIAS "${GIT_KEYMAP[@]}"

function git_keymap {
	keymap_invoke $GIT_NAMESPACE $GIT_ALIAS ${#GIT_KEYMAP} "${GIT_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

export EDITOR='mate --wait'

function git_keymap_b {
	local branches; branches=$(git branch)
	local merged; merged=$(gb_merged)

	if [[ -n $merged ]]; then
		branches+="\n----------------\n$merged"
	fi

	echo "$branches" | args_keymap_s
}

function git_keymap_bb {
	gb_merged | xargs git branch --delete
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
