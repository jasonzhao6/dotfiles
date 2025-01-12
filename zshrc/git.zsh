# [B]ranch
# [G]it checkout
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
function ga { git stash apply "stash@{${1:-0}}"; }
function gl { git stash list --pretty=format:'%C(yellow)%gd %C(magenta)%as %C(green)%s'; }
function gc { git stash clear; }
# Rebase
function gx { git add --all; git commit --fixup "$@"; }
function gxx { gxx_rebase "$@"; }
# Resolve conflict
function gxa { git rebase --abort; }
function gxc { git add --all; git rebase --continue; }
# [U]ndo and / or discard
function gu { git reset --soft HEAD~"$1"; }
function gz { git add --all; git reset --hard; git status; }
function guz { gu "$1"; gz; }
# G[r]ep
# (E.g `gr` to list all, `gr foo and bar` to filter)
function gr { local greps; greps="--grep='${*// /' --grep='}'"; eval "git log $GR_FIRST_PARENT ${1:+--all} $greps --all-match --extended-regexp --regexp-ignore-case --pretty=format:\"%C(yellow)%h %C(magenta)%as %C(green)'%s' %C(cyan)%an\""; }
function grr { GR_FIRST_PARENT=--first-parent gr "$@"; }

#
# Helpers
#

function gb_merged {
	git branch --merged | egrep --invert-match '^\*.*$|^  main$|^  master$'
}

function gxx_rebase {
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
