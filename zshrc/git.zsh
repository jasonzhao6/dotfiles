# TODO

## [G]it
# config
export EDITOR='mate --wait'
function g0 { git config --global $@ false }
function g1 { git config --global $@ true }
# remo[t]e
function gt { git remote $@ }
function gta { git remote add $1 $2 }
function gtr { git remote remove $@ }
function gtv { git remote --verbose }
# [b]ranch
function gb { GB=$(gb-merged); [[ $GB ]] && GB="\n----------------\n$GB"; echo "$(git branch)$GB" | ss }
function gbb { gb-merged | xargs git branch --delete; git remote prune origin; echo; gb }
function gbd { git branch --delete --force $@; git push origin --delete $@; gb }
# [g]it checkout
function g { git checkout $@ }
function gg { git checkout main || git checkout master; git pull; git status }
function gn { gg; git checkout -b $@ }
# git [d]iff / status
function gd { git diff }
function gq { git status }
# commit
function ge { git commit --allow-empty -m 're-run: Empty commit to trigger build' }
function gm { git add --all; git commit --amend --no-edit }
function gw { git add --all; git commit --amend }
function gv { git add --all; git commit }
function gi { git cherry-pick $@ }
# [p]ush / [P]ull
function gp { git push }
function gf { git push --force }
function gP { git pull $@ }
# [s]tash
function gs { git add --all; git stash save $@ }
function ga { git stash apply "stash@{${@:-0}}" }
function gl { git stash list --pretty=format:'%C(yellow)%gd %C(magenta)%as %C(green)%s' }
function gc { git stash clear }
# rebase
function gx { git add --all; git commit --fixup $@ }
function gxx { gxx-pre! $@; [[ -n $GXX_HEAD_NUM ]] && gxx-head-num || gxx-main-branch }
# rebase conflict
function gxa { git rebase --abort }
function gxc { git add --all; git rebase --continue }
# [u]ndo and / or discard
function gu { git reset --soft HEAD~$@ }
function gz { git add --all; git reset --hard; git status }
function guz { gu $@; gz }
# g[r]ep
# (e.g `gr` to list all, `gr foo and bar` to filter)
function gr { GR_GREPS="--grep='${*// /' --grep='}'"; eval "git log ${1:+--all} $GR_FIRST_PARENT $GR_GREPS --all-match --extended-regexp --regexp-ignore-case --pretty=format:\"%C(yellow)%h %C(magenta)%as %C(green)'%s' %C(cyan)%an\"" }
function grr { GR_FIRST_PARENT=--first-parent gr $@ }
# helper for `gb`
function gb-merged { git branch --merged | grep --invert-match 'main$' | grep --invert-match 'master$' | grep --invert-match '^\*' }
# helpers for `gxx`
function gxx-main-branch { git fetch $GXX_REMOTE $GXX_BRANCH && git rebase --interactive --autosquash $GXX_REMOTE/$GXX_BRANCH }
function gxx-head-num { git rebase --interactive --autosquash HEAD~$(($GXX_HEAD_NUM + 1)) } # `+ 1` to cover the `fixup!` commit
function gxx-pre! { # (`!` means the function sets env vars to be consumed by its caller)
    GXX_REMOTE=origin
    GXX_BRANCH=main
    GXX_HEAD_NUM=

    [[ -z $1 ]] && return

    for var in $@; do
        case $var in
            u) GXX_REMOTE=upstream;;
            m) GXX_BRANCH=master;;
            *) GXX_HEAD_NUM=$var;;
        esac
    done
}
