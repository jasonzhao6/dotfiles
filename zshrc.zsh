### Colors
# config
export GREP_COLOR='1;32'
export LSCOLORS='gxcxbxexfxegedabagaced'
export JQ_COLORS='1;35:1;35:1;35:1;35:1;32:1;33:1;33:1;36' # v1.7+
# set foreground
function grep-highlighting { echo "\e[1;32m\e[K$@\e[m\e[K" }
# set background
function red-bg { echo "\e[41m$@\e[0m" }
function green-bg { echo "\e[42m$@\e[0m" }
# switch modes
function bw { # black and white
    unalias diff
    unalias egrep
    unalias grep
    unalias ls
}
function color {
    alias diff='colordiff'
    alias egrep='egrep --color=always'
    alias grep='grep --color=always'
    alias ls='ls --color=always'
}; color # enable these aliases ahead of function definitions, so that they will expand

### [Args]
# [s]ave into args history
# (e.g `seq 100 105; s`, or alternatively `seq 100 105 | s`)
function s { ss 'insert `#` after the first column to soft-select it' }
function ss { [[ -t 0 ]] && eval $(prev-command) | save-args $@ || save-args $@ }
# paste into args history
# (e.g copy a list to pasteboard, then `v`)
function v { pbpaste | s }
function vv { pbpaste | ss }
# list / filter [a]rgs
# (e.g `a` to list all, `a foo and bar -not -baz` to filter)
function a { [[ -z $1 ]] && args-list || { args-build-greps! $@; args-plain | eval "$ARGS_FILTER | $ARGS_HIGHLIGHT" | save-args } }
# use an [arg] by number
# (e.g `arg <number> echo`, or with explicit positioning `arg <number> echo ~~`)
function arg { [[ -n $1 && -n $2 ]] && { ARG="$(args-plain | sed -n "$1p" | sed 's/ *#.*//' | strip)"; [[ $(index-of ${(j: :)@} '~~') -eq 0 ]] && echo-eval "${@:2} $ARG" || echo-eval ${${@:2}//~~/$ARG} } }
function 1 { arg $0 $@ }
function 2 { arg $0 $@ }
function 3 { arg $0 $@ }
function 4 { arg $0 $@ }
function 5 { arg $0 $@ }
function 6 { arg $0 $@ }
function 7 { arg $0 $@ }
function 8 { arg $0 $@ }
function 9 { arg $0 $@ }
function 10 { arg $0 $@ }
function 11 { arg $0 $@ }
function 12 { arg $0 $@ }
function 13 { arg $0 $@ }
function 14 { arg $0 $@ }
function 15 { arg $0 $@ }
function 16 { arg $0 $@ }
function 17 { arg $0 $@ }
function 18 { arg $0 $@ }
function 19 { arg $0 $@ }
function 20 { arg $0 $@ }
function 0 { arg $ $@ } # last arg
# use a [r]andom arg
# (e.g `rr echo`)
function rr { arg $((RANDOM % $(args-list-size) + 1)) $@ }
# use args within a rang[e]
# (e.g `e 2 5 echo`, or with explicit positioning `e 2 5 echo ~~ and ~~ again`)
function e { for i in $(seq $1 $2); do echo; arg $i ${${@:3}}; done }
# use all args via an iterator
# (e.g `each echo`, `all echo`, `map echo '$((~~ * 2))'`)
function each { ARGS_ROW_SIZE=$(args-list-size); for i in $(seq 1 $ARGS_ROW_SIZE); do echo; arg $i $@; done }
function all { ARGS_ROW_SIZE=$(args-list-size); for i in $(seq 1 $ARGS_ROW_SIZE); do echo; arg $i $@ &; done; wait }
function map { ARGS_ROW_SIZE=$(args-list-size); ARGS_MAP=''; for i in $(seq 1 $ARGS_ROW_SIZE); do echo; ARG=$(arg $i $@); echo $ARG; ARGS_MAP+="$ARG\n"; done; echo; echo $ARGS_MAP | save-args }
# list / select a colum[n] by letter
# (e.g `n` to list all, `n d` to select the fourth column based on the bottom row)
function n { [[ $NN -eq 1 ]] && N=0 || N=1; [[ -z $1 ]] && { args-list; args-columns-bar $N } || { args-mark-references! $1 $N; args-select-column!; [[ $ARGS_PUSHED -eq 0 && $(index-of "$(args-columns $N)" b) -ne 0 ]] && args-columns-bar $N }; return 0 }
# (`nn` is like `n`, but based on the top row instead of bottom row)
function nn { NN=1 n $@ }
# select the first column
function aa { [[ -z $N || $N -eq 1 ]] && n a || nn a }
# strip leading / trailing spaces from all args
function z { args | strip | save-args }
# [c]opy into pasteboard
# (e.g `c` to copy all args, `11 c` to copy only the eleventh arg)
function c { [[ -z $1 ]] && args-plain | pbcopy || echo -n $@ | pbcopy }
# [u]ndo / [r]edo changes, up to `ARGS_HISTORY_MAX`
function u { ARG_SIZE_PREV=$(args-columns | strip); args-undo; args-list; args-undo-bar; ARG_SIZE_CURR=$(args-columns | strip); [[ ${#ARG_SIZE_PREV} -lt ${#ARG_SIZE_CURR} ]] && args-columns-bar }
function r { args-redo; args-list; args-redo-bar }
# [y]ank / [p]ut current args into a different tab
function y { args > ~/.zshrc.args }
function p { echo "$(<~/.zshrc.args)" | save-args }
# helpers
function args { echo $ARGS_HISTORY[$ARGS_CURSOR] }
function args-plain { args | no-color | expand }
function args-list { args | nl }
function args-list-plain { args | nl | no-color | expand }
function args-list-size { args | wc -l | awk '{print $1}' }
function args-columns { ARGS_COLUMNS=''; ARGS_COL_CURR=a; ARGS_SKIP_NL=1; [[ ${1:-$ARGS_BOTTOM_ROW} -eq 1 ]] && ARG=$(args-list-plain | tail -1) || ARG=$(args-list-plain | head -1); for i in $(seq 1 ${#ARG}); do args-label-column! $i; done; echo $ARGS_COLUMNS }
function args-columns-bar { green-bg "$(args-columns $1)" }
# helpers! (`!` means the function sets env vars to be consumed by its caller)
function args-build-greps! { ARGS_FILTER="grep ${*// / | grep }"; ARGS_FILTER=${ARGS_FILTER// -/ --invert-match }; ARGS_FILTER=${ARGS_FILTER//grep/grep --color=never --ignore-case}; ARGS_HIGHLIGHT="egrep --color=always --ignore-case '${${@:#-*}// /|}'" }
function args-label-column! { [[ $ARG[$1-1] == ' ' && $ARG[$1] != ' ' ]] && { [[ $ARGS_SKIP_NL -eq 1 ]] && { ARGS_SKIP_NL=0; ARGS_COLUMNS+=' ' } || { ARGS_COLUMNS+=$ARGS_COL_CURR; ARGS_COL_CURR=$(next-ascii $ARGS_COL_CURR) } } || ARGS_COLUMNS+=' ' }
function args-mark-references! { ARGS_COLUMNS=$(args-columns $2); ARGS_COL_FIRST=$(index-of $ARGS_COLUMNS a); ARGS_COL_TARGET=$(index-of $ARGS_COLUMNS $1); ARGS_COL_NEXT=$(index-of $ARGS_COLUMNS $(next-ascii $1)); ARGS_BOTTOM_ROW=$2 }
function args-select-column! { args-list-plain | cut -c $([[ $ARGS_COL_TARGET -ne 0 ]] && echo $ARGS_COL_TARGET || echo $ARGS_COL_FIRST)-$([[ $ARGS_COL_NEXT -ne 0 ]] && echo $((ARGS_COL_NEXT - 1))) | strip | save-args }
function args-get-new! { ARGS_NEW=$(cat - | head -1000 | no-empty); [[ -n $1 ]] && ARGS_NEW=$(echo $ARGS_NEW | insert-hash); ARGS_NEW_PLAIN=$(echo $ARGS_NEW | no-color | expand) }
function args-push-if-different! { [[ $ARGS_NEW_PLAIN != $(args-plain) ]] && { args-push $ARGS; ARGS_PUSHED=1 } || ARGS_PUSHED=0 }
# | after a list
function save-args { args-get-new! $1; [[ -n $ARGS_NEW ]] && { args-push-if-different!; args-replace $ARGS_NEW; args-list } } # always replace in case grep highlighting has updated

### Args history interface
#
#             123456789
#  cursor     ^
#  head       ^
#  tail       ^
#
# - array size is fixed, wrap around the end
# - advance `cursor` and `head` together
# - if next is `tail`, push `tail` forward
# - to undo, only `cursor` moves, up to `tail`
# - to redo, only `cursor` moves, up to `head`
function args-init { ARGS_HISTORY_MAX=100; ARGS_HISTORY=(); ARGS_CURSOR=0; ARGS_HEAD=0; ARGS_TAIL=0 }; [[ -z $ARGS_HISTORY_MAX ]] && args-init
function args-push { ARGS_CURSOR=$(args-increment $ARGS_CURSOR); ARGS_HISTORY[$ARGS_CURSOR]=$1; ARGS_HEAD=$ARGS_CURSOR; [[ $ARGS_CURSOR -eq $ARGS_TAIL ]] && ARGS_TAIL=$(args-increment $ARGS_TAIL); [[ $ARGS_TAIL -eq 0 ]] && ARGS_TAIL=1 }
function args-undo { ARGS_PREV=$(args-decrement $ARGS_CURSOR); [[ $ARGS_CURSOR -ne $ARGS_TAIL ]] && ARGS_CURSOR=$ARGS_PREV || ARGS_UNDO_EXCEEDED=1 }
function args-redo { ARGS_NEXT=$(args-increment $ARGS_CURSOR); [[ $ARGS_CURSOR -ne $ARGS_HEAD ]] && ARGS_CURSOR=$ARGS_NEXT || ARGS_REDO_EXCEEDED=1 }
function args-undo-bar { [[ $ARGS_UNDO_EXCEEDED -eq 1 ]] && { ARGS_UNDO_EXCEEDED=0; red-bg 'Reached the end of undo history' } }
function args-redo-bar { [[ $ARGS_REDO_EXCEEDED -eq 1 ]] && { ARGS_REDO_EXCEEDED=0; red-bg 'Reached the end of redo history' } }
function args-replace { ARGS_HISTORY[$ARGS_CURSOR]=$1 }
function args-increment { echo $(($1 % ARGS_HISTORY_MAX + 1)) }
function args-decrement { ARGS_DECREMENT=$(($ARGS_CURSOR - 1)); [[ $ARGS_DECREMENT -eq 0 ]] && ARGS_DECREMENT=$ARGS_HISTORY_MAX; echo $ARGS_DECREMENT }
# debug
function args-history {
	echo "cursor: $ARGS_CURSOR"
	echo "head: $ARGS_HEAD"
	echo "tail: $ARGS_TAIL"
	echo "max: $ARGS_HISTORY_MAX"

	local index=$ARGS_HEAD

	# Print from head to tail, inclusive
	while true; do
		echo
		echo '----------------------------------------'
		echo "Index $index"
		echo '----------------------------------------'
		echo ${ARGS_HISTORY[index]}

		[[ $index -eq $ARGS_TAIL ]] && break

		# Decrement index accounting for wrap-around and 1-based indexing
		index=$(((index - 2 + $ARGS_HISTORY_MAX) % $ARGS_HISTORY_MAX + 1))
	done
}

### AWS
# select region
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-'us-east-1'}
function c1 { echo-eval 'export AWS_DEFAULT_REGION=eu-central-1' }
function e1 { echo-eval 'export AWS_DEFAULT_REGION=us-east-1' }
function e2 { echo-eval 'export AWS_DEFAULT_REGION=us-east-2' }
function w1 { echo-eval 'export AWS_DEFAULT_REGION=us-west-1' }
function w2 { echo-eval 'export AWS_DEFAULT_REGION=us-west-2' }
# find [ec2] / [asg] instances by name tag prefix
function ec2 { ecc $@ }
function ecc { ec2-args "Name=tag:Name, Values=$@*" }
function asg { ec2-args "Name=tag:aws:autoscaling:groupName, Values=$@*" }
# open [ec2] / [asg] page by resource id
function oec2 { oecc $@ }
function oecc { open "https://$AWS_DEFAULT_REGION.console.aws.amazon.com/ec2/home?region=$AWS_DEFAULT_REGION#InstanceDetails:instanceId=$(ec2-id $@)" }
function oasg { open "https://$AWS_DEFAULT_REGION.console.aws.amazon.com/ec2/home?region=$AWS_DEFAULT_REGION#AutoScalingGroupDetails:id=$@" }
# use [ssm] to ssh into ec2 by instance id, private ip, or name tag
function ssm { # (e.g `ssm <instance-id>`, or `0 ssm` to use the last entry from `args`)
    aws ssm start-session \
        --document-name 'AWS-StartInteractiveCommand' \
        --parameters '{"command": ["sudo -i"]}' \
        --target $(ec2-id $@)
}
function ssm_ { aws ssm start-session --target $(ec2-id $@) }
function ssm-cmd { # (e.g `ssm-run date <instance-id>`, or `each ssm-run date` to iterate through `args`)
    aws ssm start-session \
        --document-name 'AWS-StartNonInteractiveCommand' \
        --parameters "{\"command\": [\"${(j: :)@[1,-2]}\"]}" \
        --target $(ec2-id $@[-1]) \
    | pcregrep --multiline --ignore-case --invert-match "(Starting|\nExiting) session with SessionId: [a-z0-9-@\.]+(\n\n)*"
}
# [p]arameter [s]tore [g]et
function psg { PSG=$(aws ssm get-parameter --name $1 $([[ -n $2 ]] && echo --version $2) --query Parameter.Value --output text); [[ $PSG == {*} ]] && echo $PSG | jq || echo $PSG }
# [s]ecrets [m]anager [g]et / [d]elete
function smg { SMG=$(aws secretsmanager get-secret-value --secret-id $1 $([[ -n $2 ]] && echo --version-id $2) --query SecretString --output text); [[ $SMG == {*} ]] && echo $SMG | jq || echo $SMG }
function smd { aws secretsmanager delete-secret --secret-id $@ --force-delete-without-recovery }
# [decode] sts message
function decode { aws sts decode-authorization-message --encoded-message $@ --output text | jq . }
# helpers
function ec2-args { aws ec2 describe-instances --filters $@ 'Name=instance-state-name, Values=running' --query "$(ec2-query)" --output text | sort --key=3 | sed 's/+00:00\t/Z  /g' | s }
function ec2-query { echo 'Reservations[].Instances[].[PrivateIpAddress, LaunchTime, Tags[?Key==`Name` || Key==`aws:autoscaling:groupName`].Value|[0]]' }
function ec2-id { [[ $@ =~ ^(i-)?[a-z0-9]{17}$ ]] && { [[ $@ =~ ^i-.*$ ]] && echo $@ || echo i-$@ } || { [[ $@ =~ ^[0-9\.]+$ ]] && ip-id $@ || name-id $@ } }
function id-name { aws ec2 describe-instances --filters "Name=instance-id, Values=$@" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text }
function ip-id { aws ec2 describe-instances --filters "Name=private-ip-address, Values=$@" --query 'Reservations[].Instances[].InstanceId' --output text }
function name-id { aws ec2 describe-instances --filters "Name=tag:Name, Values=$@" --query 'Reservations[].Instances[].InstanceId' --output text }

### [C]hange [d]ir
# go up folders
function .. { cd .. }
function ... { cd ../.. }
function .... { cd ../../.. }
function ..... { cd ../../../.. }
function ...... { cd ../../../../.. }
function ....... { cd ../../../../../.. }
function ........ { cd ../../../../../../.. }
function ......... { cd ../../../../../../../.. }
function .......... { cd ../../../../../../../../.. }
# go to a folder
function cd- { CD=$(paste-when-empty $@); [[ -d $CD ]] && cd $CD || cd ${${CD}%/*} }
# go to mac folders
function cdl { cd ~/Downloads }
function cdm { cd ~/Documents }
function cdt { cd ~/Desktop }
function tmp { cd /tmp }
# go to github folders
# TODO reorg as ~/github/<org>/<repo>
function cdd { cd ~/gh/dotfiles }
function cde { cd ~/gh/excalidraw; ruby _touch.rb; oo }
function cdg { cd ~/gh }
function cdj { cd ~/gh/jasonzhao6 }
function cds { cd ~/gh/scratch }
function cdtf { cd ~/gh/scratch/tf-debug }

### [G]it
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
function gb { GB=$(gb-merged); [[ $GB ]] && GB="\n----------------\n$GB"; echo "$(git branch)$GB" | save-args }
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
function gz { git add --all; git reset --hard; gi }
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

### Github
# open in browser
function main { open https://$(domain)/$(org)/${@:-$(repo)} }
function new { gp && gh pr create --fill && gh pr view --web }
function pr { open https://$(domain)/$(org)/$(repo)/pull/$@ }
function prs { open "https://$(domain)/pulls?q=is:open+is:pr+user:$(org)" }
function sha { open https://$(domain)/$(org)/$(repo)/commit/$@ }
# helpers
function domain { git remote get-url origin | sed 's/.*[:/]\([^/]*\)\/.*\/.*/\1/' }
function org { git remote get-url origin | sed 's/.*[:/]\([^/]*\)\/.*/\1/' }
function repo { git rev-parse --show-toplevel | xargs basename }
function branch { git rev-parse --abbrev-ref HEAD }

### [K]ubectl
# TODO move to eof once stable
### Kubectl keymap
#  1   2   3   4   5  |  6   7   8   9   0
#             [p] [y] |  f  [g] [c] [r] [l]
#  a   o  [e]  u   i  | [d]  h   t   n  [s]
#     [q] [j] [k] [x] | [b]  m   w   v   z
# resources ref: g[r]ep / [s]ave / e[x]plain
function kr { cat ~/Documents/k8.txt | grep "$*" | save-args }
function ks { kubectl api-resources > ~/Documents/k8.txt }
function kx { kubectl explain $@ }
# set [n]ame[s]pace
function kns { kubectl config set-context --current --namespace $@ }
# general
function k { kubectl $@ }
function kd { kubectl describe $@ }
function ke { kubectl exec $@ }
function kg { kubectl get $@ }
function kk { kubectl get $@ | save-args }
# pod shortcuts
function kb { kubectl exec -it $@ -- bash }
function kc { kubectl exec $@[-1] -- $@[1,-2] }
function kl { kubectl logs $@ }
function kp { kubectl port-forward $@ }
# get resource as [j]son / [y]aml
function kj { [[ -n $1 ]] && kubectl get $@ -o json > ~/Documents/k8.json | jq }
function kjj { cat ~/Documents/k8.json }
function ky { [[ -n $1 ]] && kubectl get $@ -o yaml > ~/Documents/k8.yaml | cat }
function kyy { cat ~/Documents/k8.yaml }
# [q]uery saved json output
function kq { jq ${@:-.} ~/Documents/k8.json }

### [T]erra[f]orm
# config
function tf0 { echo-eval 'export TF_LOG=' }
function tf1 { echo-eval 'export TF_LOG=DEBUG' }
# [i]nit
function tfi { mkdir -p ~/.terraform.cache; terraform init $@ }
function tfiu { terraform init -upgrade }
function tfir { terraform init -reconfigure }
function tfim { terraform init -migrate-state }
# post `tfi`
# (e.g `tfp` to plan, `tfp iu` to init upgrade then plan)
function tfp { tf-pre $@ && terraform plan -out=tfplan }
function tfl { tf-pre $@ && terraform state list | sed "s/.*/'&'/" | save-args }
function tfo { tf-pre $@ && terraform output }
function tfn { tf-pre $@ && terraform console }
function tfv { tf-pre $@ && terraform validate }
# post `tfp`
function tfa { terraform apply }
function tfd { terraform destroy }
function tfg { terraform show -no-color tfplan | sed 's/user_data.*/user_data [REDACTED]/' | gh gist create --web }
function tfz { terraform force-unlock $@ }
# post `tfl`
function tfs { terraform state show $@ }
function tft { terraform taint $@ }
function tfu { terraform untaint $@ }
function tfm { terraform state mv $1 $2 }
function tfr { terraform state rm $@ }
# [f]ormat file / folder
function tff { terraform fmt -recursive $@ }
# [c]lear cache
function tfc { rm -rf tfplan .terraform ~/.terraform.d }
function tfcc { rm -rf tfplan .terraform ~/.terraform.d ~/.terraform.cache }
# non-prod shortcut
function tfaa { tf-pre $@ && terraform apply -auto-approve }
# helpers
function tf { pushd ~/gh/scratch/tf-debug > /dev/null; [[ -z $1 ]] && terraform console || echo "local.$@" | terraform console; popd > /dev/null }
function tf-pre {
    [[ -z $1 ]] && return

    for var in $@; do
        case $var in
            e) tfe;;
            i) tfi;;
            iu) tfiu;;
            ir) tfir;;
            im) tfim;;
        esac
    done
}

### Util
# singles (they save into `args`)
function d { [[ -n $1 ]] && { D=${${${@}#*://}%%/*}; [[ -z $D_UNDER_TEST ]] && dig +short $D | save-args || echo "test output for\n$D" | ss } }
function f { [[ -n $1 ]] && f-pre $@ | sort | save-args }
function i { which $@ | save-args }
function l { ls -l | awk '{print $9}' | save-args } # Not taking search pattern b/c folder matches break column alignment
function ll { ls -lA | awk '{print $9}' | egrep --color=never '^(\e\[3[0-9]m)?\.' | save-args } # Show only hidden files
# doubles (they do not save into `args`)
function bb { pmset sleepnow }
function cc { eval $(prev-command) | no-color | ruby -e 'puts STDIN.read.strip' | pbcopy }
function dd { mkdir -p $DD_DUMP_DIR; dd-is-terminal-output && { DD=$(dd-dump-file); $(pbpaste > $DD); dd-taint-pasteboard; dd-clear-terminal } || dd-clear-terminal }
function ddd { mkdir -p $DD_DUMP_DIR; cd $DD_DUMP_DIR }
function ddc { rm -rf $DD_DUMP_DIR }
function ee { for i in $(seq $1 $2); do echo ${${@:3}//~~/$i}; done }
function eee { for i in $(seq $1 $2); do echo; echo-eval ${${@:3}//~~/$i}; done }
function ff { caffeinate }
function hh { diff --side-by-side --suppress-common-lines $1 $2 }
function ii { open -na 'IntelliJ IDEA CE.app' --args ${@:-.} }
function mm { mate ${@:-.} }
function oo { open ${@:-.} }
function pp { ruby ~/gh/jasonzhao6/sql_formatter.rb/run.rb $@ }
function tt { ~/gh/tt/tt.rb $@ }
function uu { diff --unified $1 $2 }
function xx { echo "bind '\"\\\e[A\": history-search-backward'\nbind '\"\\\e[B\": history-search-forward'" | pbcopy }
function yy { YY=$(prev-command); echo -n $YY | pbcopy }
# one-offs
function bif { brew install --formula $@ }
function flush { sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder }
function jcurl { curl --silent $1 | jq | { [[ -z $2 ]] && cat || grep -A${3:-0} -B${3:-0} $2 } }
function ren { for file in *$1*; do mv "$file" "${file//$1/$2}"; done }
# helpers
function echo-eval { echo $@ >&2; eval $@ }
function ellipsize { [[ ${#1} -gt $COLUMNS ]] && echo -n "${1:0:$((COLUMNS - 4))} \e[30m\e[47m...\e[0m" || echo $@ }
function has-internet { curl -s --max-time 1 http://www.google.com &> /dev/null }
function index-of { awk -v str1="$(echo $1 | no-color)" -v str2="$(echo $2 | no-color)" 'BEGIN { print index(str1, str2) }' }
function next-ascii { printf "%b" $(printf "\\$(printf "%o" $(($(printf "%d" "'$@") + 1)))") }
function paste-when-empty { echo ${@:-$(pbpaste)} }
function prev-command { fc -ln -1 }
# helper for `f`
function f-pre {
	[[ $@ == gh ]] && gh repo list $(org) --no-archived --limit 1000 --json name | jq -r '.[].name'
	[[ $@ == tf ]] && find ~+ -name main.tf | grep --invert-match '\.terraform' | sed "s|$HOME|~|g" | trim 0 8
}
# helpers for `dd`
function dd-init { DD_DUMP_DIR="$HOME/.zshrc.terminal-dump.d"; DD_CLEAR_TERMINAL=1 }; dd-init
function dd-is-terminal-output { [[ $(pbpaste | no-empty | strip | sed -n '$p') == \$* ]] }
function dd-dump-file { echo "$DD_DUMP_DIR/$(gdate +'%Y-%m-%d_%H.%M.%S.%6N').txt" }
function dd-taint-pasteboard { $(echo "$(pbpaste)\n\n(Dumped to '$DD')" | pbcopy) }
function dd-clear-terminal { [[ $DD_CLEAR_TERMINAL -eq 1 ]] && clear }
# | after strings
function hex { hexdump -C }
function no-color { sed -E 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g' }
function no-empty { sed '/^$/d' }
function strip { sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' }
function trim { no-color | cut -c $(($1 + 1))- | { [[ -z $2 ]] && cat || rev | cut -c $(($2 + 1))- | rev } }
# | after columns
function insert-hash { awk 'NF >= 2 {col_2_index = index($0, $2); col_1 = substr($0, 1, col_2_index - 1); col_rest = substr($0, col_2_index); printf "%s# %s\n", col_1, col_rest} NF < 2 {print}' }
function size-of { awk "{if (length(\$${1:-0}) > max_len) max_len = length(\$${1:-0})} END {print max_len}" }
# | after json
function keys { jq keys | trim-list | save-args }
function trim-list { sed -e 's/^\[//' -e 's/^]//' -e 's/^ *"//' -e 's/",\{0,1\}$//' | no-empty }

### [Z]shrc
# edit
function zm { mate ~/gh/dotfiles/zshrc.zsh }
function zs { mate ~/.zshrc.secrets }
# [t]est
function zt { zsh ~/gh/dotfiles/zshrc-tests.zsh $@ }
# source
function zz { source ~/.zshrc }
# [u]pload / [d]ownload other dotfiles
function zu {
    cp ~/.colordiffrc ~/gh/dotfiles/colordiffrc.txt
    cp ~/.gitignore ~/gh/dotfiles/gitignore.txt
    cp ~/.terraformrc ~/gh/dotfiles/terraformrc.txt
    cp ~/.tm_properties ~/gh/dotfiles/tm_properties.txt

    if [[ -f ~/.zshrc.secrets ]]; then
        openssl sha1 ~/.zshrc.secrets > ~/.zshrc.secrets_sha1_candidate
        diff ~/.zshrc.secrets_sha1_candidate ~/.zshrc.secrets_sha1 > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            cp ~/.zshrc.secrets_sha1_candidate ~/.zshrc.secrets_sha1
            cp ~/.zshrc.secrets ~/Downloads/\>\ Archive/zsh/.zshrc.secrets/$(date +'%y.%m.%d').txt
        fi
    fi
}
[ -f ~/.zshrc.secrets ] && source ~/.zshrc.secrets
function zd {
    cp ~/gh/dotfiles/colordiffrc.txt ~/.colordiffrc
    cp ~/gh/dotfiles/gitignore.txt ~/.gitignore
    cp ~/gh/dotfiles/terraformrc.txt ~/.terraformrc
    cp ~/gh/dotfiles/tm_properties.txt ~/.tm_properties
}

### Zsh arrow keys
# history search (up / down)
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end
# word separators (left / right)
WORDCHARS=${WORDCHARS/\.} # exclude .
WORDCHARS=${WORDCHARS/\/} # exclude /
WORDCHARS=${WORDCHARS/\=} # exclude =
WORDCHARS+='|'

### Zsh [h]istory
# config
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
# list / filter
# (e.g `h` to list all, `h foo` to filter)
function h { egrep --ignore-case "$*" $HISTFILE | trim 15 | sort --unique | save-args }
# [c]lear
function hc { rm $HISTFILE }
# edit
function hm { mate $HISTFILE }
# session persistence
function h0 { unset -f zshaddhistory }              #  disk &&  memory
function h1 { function zshaddhistory { return 1 } } # !disk && !memory
function h2 { function zshaddhistory { return 2 } } # !disk &&  memory

### Zsh prompt
# config
setopt PROMPT_SUBST
# composition
# - Line 1: <empty>
# - Line 2:
#   - Variation A: @repo/path #branch (sts-info region-info tf-info)
#   - Variation B: ~/home/path (...)
#   - Variation C: /root/path (...)
# - Line 3: $ █
PROMPT=\
$'\n'\
'%{%F{yellow}%}% ${${PWD/#$HOME/~}/\~\/gh\//@}'\
'%{%F{cyan}%}% $(branch-info)'\
'%{%F{green}%}% $(sts-info)'\
'%{%F{magenta}%}% $(region-info)'\
'%{%F{yellow}%}% $(tf-info)'\
$'\n'\
'%{%F{yellow}%}% $'\
'%{%f%}%  '
# helpers
function branch-info { BRANCH_INFO=$(branch 2> /dev/null); [[ -n $BRANCH_INFO ]] && echo " #$BRANCH_INFO" }
function region-info { [[ -n $(aws-profile) ]] && echo " $AWS_DEFAULT_REGION" }
function sts-info { [[ -n $(aws-profile) ]] && { set-sts-info; echo " $(<$STS_INFO_DIR/$(aws-profile))" } }
function tf-info { [[ -n $TF_VAR_datadog_api_key ]] && echo ' TF_VAR' }
# helpers for `sts-info`
STS_INFO_DIR="$HOME/.zshrc.sts-info.d"
function reset-sts-info { rm -rf $STS_INFO_DIR }
function set-sts-info { [[ ! -e $STS_INFO_DIR/$(aws-profile) ]] && { mkdir -p $STS_INFO_DIR; echo "$(account)::$(role)" > $STS_INFO_DIR/$(aws-profile) } }
function account { aws iam list-account-aliases --query 'AccountAliases[0]' --output text }
function aws-key { [[ -n $AWS_ACCESS_KEY_ID ]] && echo $AWS_ACCESS_KEY_ID }
function aws-profile { { [[ -n $AWS_PROFILE ]] && echo $AWS_PROFILE } }
function role { ROLE=$(aws sts get-caller-identity --query Arn --output text | awk -F'/' '{print $2}'); [[ $ROLE == *_* ]] && echo $ROLE | awk -F'_' '{print $2}' || echo $ROLE }

### Keymap annotations
#  ::  -->  subsequent command
#  |   -->  alternative command
#  ~   -->  repeatable command
#  ()  -->  order of precedence
#  ,   -->  argument separator
#  ?   -->  optional command / argument
#  #   -->  number argument
#  .   -->  letter argument
#  *   -->  arbitrary argument
#  ~~  -->  to be substituted
#  ""  -->  quotes recommended
#  %+v -->  `cmd + v` to paste

### Git keymap
# [] means defined in this file
# <> means already taken, e.g `go`
# [1]  2   3   4   5  |  6   7   8   9  [0]   <--   g1|g0   gt|gtv|gta|gtr   gb::#,(g|gbb|gbd)   gg|(gn,*)
#             [p]  y  | [f] [g] [c] [r] [l]   <--   gd|gq   ge|gm|gw|gv|gi   gp|gf|gP   gs,*?::(ga,#?)|gl|gc
# [a] <o> [e] [u] [i] | [d] <h> [t] [n] [s]   <--   gx,*::gxx,(u|m|#)?::(gxa|gxc)?   (gu|gz|guz),#?
#     [q]  j   k  [x] | [b] [m] [w] [v] [z]   <--   (gr|gr-),*?::s::#,sha

### Terraform keymap
# [] means defined in this file
# {} means defined in secrets file
# [1]  2   3   4   5  |  6   7   8   9  [0]   <--   tf1|tf0   tfi|tfiu|tfir|tfim
#             [p]  y  | [f] [g] [c] [r] [l]   <--   tfi::(tfp|tfl|tfo|tfn|tfv),(e|i|iu|ir|im)?::tf?
# [a] [o] {e} [u] [i] | [d]  h  [t] [n] [s]   <--   tfp::tfa|tfd|tfg|(tfz,*)   tfl::(tfs|tft|tfu|tfm|tfr),*
#      q   j   k   x  |  b  [m]  w  [v] [z]   <--   tfc|tfcc   f,tf::(a,*)?::#,cd

### Singles keymap
# () means defined for `args`
# [] means defined in this file
# {} means defined in secrets file
# (1) (2) (3) (4) (5) | (6) (7) (8) (9) (0)
#             (p) (y) | [f] [g] (c) (r) [l]   <--   s|ss|v|vv::a|n   a,*?,-*?::~?::#   ((n|nn),.?)|aa|z::#
# (a) {o} (e) (u) [i] | [d] [h]  t  (n) (s)   <--   #|rr|each|all|map,*,~~?   e,#,#,*,~~?   #?,c::%+v
#     {q} {j} [k]  x  |  b   m  {w} (v) (z)   <--   u|r::~?   y::p   d|(f,(gh|tf))|h|(i,*)|kk|l|ll::a

### Doubles keymap
# () means defined for `args`
# [] means defined in this file
# {} means defined in secrets file
# (1)  2   3   4   5  |  6   7   8   9   0
#             [p] [y] | [f] [g] [c] (r) [l]   <--   pp,""?,*?::cc   yy|cc|xx::%+v   ff|bb   l|ll::a
# (a) [o] [e] [u] [i] | [d] [h] [t] (n) (s)   <--   oo|ii|mm   ee,#,#,*,~~::eee   uu|hh   dd::ddd|ddc
#     {q} {j} [k] [x] | [b] [m] {w} (v) [z]   <--   qq|q2::q   jj::#,j   ww::#,w   zz|zt
