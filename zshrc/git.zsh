# Commit
# [P]ull / [p]ush
function gP { git pull "$@"; }
function gp { git push; }
function gf { git push --force; }
# [S]tash# Rebase
# [U]ndo and / or discard
# G[r]ep
# (E.g `gr` to list all, `gr foo and bar` to filter)
function gr { local greps; greps="--grep='${*// /' --grep='}'"; eval "git log $GR_FIRST_PARENT ${1:+--all} $greps --all-match --extended-regexp --regexp-ignore-case --pretty=format:\"%C(yellow)%h %C(magenta)%as %C(green)'%s' %C(cyan)%an\""; }
function grr { GR_FIRST_PARENT=--first-parent gr "$@"; }
