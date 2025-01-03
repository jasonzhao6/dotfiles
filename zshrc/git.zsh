### [G]it
# Config
export EDITOR='mate --wait'
function g0 { git config --global "$@" false; }
function g1 { git config --global "$@" true; }
# Remo[t]e
function gt { git remote "$@"; }
function gta { git remote add "$1" "$2"; }
function gtr { git remote remove "$@"; }
function gtv { git remote --verbose; }
# [B]ranch
function gb { GB=$(gb-merged); [[ $GB ]] && GB="\n----------------\n$GB"; echo "$(git branch)$GB" | ss; }
function gbb { gb-merged | xargs git branch --delete; git remote prune origin; echo; gb; }
function gbd { git branch --delete --force "$@"; git push origin --delete "$@"; gb; }
# [G]it checkout
function g { git checkout "$@"; }
function gg { git checkout main || git checkout master; git pull; git status; }
function gn { gg; git checkout -b "$@"; }
# Git [d]iff / status
function gd { git diff; }
function gq { git status; }
# Commit
function ge { git commit --allow-empty -m 're-run: Empty commit to trigger build'; }
function gm { git add --all; git commit --amend --no-edit; }
function gw { git add --all; git commit --amend; }
function gv { git add --all; git commit; }
function gi { git cherry-pick "$@"; }
# [P]ull / [p]ush
function gP { git pull "$@"; }
function gp { git push; }
function gf { git push --force; }
# [S]tash
function gs { git add --all; git stash save "$@"; }
function ga { echo git stash apply "stash@{${1:-0}}"; }
function gl { git stash list --pretty=format:'%C(yellow)%gd %C(magenta)%as %C(green)%s'; }
function gc { git stash clear; }
# Rebase
function gx { git add --all; git commit --fixup "$@"; }
function gxx { gxx-actual "$@"; }
# Resolve conflict
function gxa { git rebase --abort; }
function gxc { git add --all; git rebase --continue; }
# [U]ndo and / or discard
function gu { git reset --soft HEAD~"$1"; }
function gz { git add --all; git reset --hard; git status; }
function guz { gu "$1"; gz; }
# G[r]ep
# (E.g `gr` to list all, `gr foo and bar` to filter)
function gr { GR_GREPS="--grep='${*// /' --grep='}'"; eval "git log ${1:+--all} $GR_FIRST_PARENT $GR_GREPS --all-match --extended-regexp --regexp-ignore-case --pretty=format:\"%C(yellow)%h %C(magenta)%as %C(green)'%s' %C(cyan)%an\""; }
function grr { GR_FIRST_PARENT=--first-parent gr "$@"; }

#
# Helpers
#

function gb-merged {
	# shellcheck disable=SC2196
	git branch --merged | egrep --invert-match '^\*.*$|^  main$|^  master$'
}

function gxx-actual {
	GXX_REMOTE=origin
	GXX_BRANCH=main
	GXX_HEAD_NUM=

	for var in "$@"; do
		case $var in
			u) GXX_REMOTE=upstream;;
			m) GXX_BRANCH=master;;
			*) GXX_HEAD_NUM=$var;;
		esac
	done

	if [[ -n $GXX_HEAD_NUM ]]; then
		# The `+ 1` is to count the `fixup!` commit itself
		git rebase --interactive --autosquash HEAD~$((GXX_HEAD_NUM + 1))
	else
		git fetch "$GXX_REMOTE" "$GXX_BRANCH" && git rebase --interactive --autosquash "$GXX_REMOTE/$GXX_BRANCH"
	fi
}
