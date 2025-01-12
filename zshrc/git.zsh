# [B]ranch
# [G]it checkout
# Git [d]iff / status
function gq { git status; }
# Commit
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
