export ZSHRC_DIR="$HOME/gh/dotfiles/zshrc"

# Enable color aliases immediately to allow alias expansion in subsequent functions
source "$ZSHRC_DIR/colors.zsh"; color

# `git_info` needs to come before `zsh_prompt`
source "$ZSHRC_DIR/git_info.zsh"

source "$ZSHRC_DIR/zsh_history.zsh"
source "$ZSHRC_DIR/zsh_prompt.zsh"

### [Args]
# [s]ave into args history
# (e.g `seq 100 105; s`, or alternatively `seq 100 105 | s`)
function s { ss 'insert `#` after the first column to soft-select it' }
function ss { [[ -t 0 ]] && eval $(prev_command) | save_args $@ || save_args $@ }
# paste into args history
# (e.g copy a list into pasteboard, then `v`)
function v { pbpaste | s }
function vv { pbpaste | ss }
# list / filter [a]rgs
# (e.g `a` to list all, `a foo and bar -not -baz` to filter)
function a { [[ -z $1 ]] && args-list || { args-build-greps! $@; args-plain | eval "$ARGS_FILTERS | $ARGS_COLOR" | ss } }
# select a random arg
# (e.g `aa echo`)
function aa { arg $((RANDOM % $(args-list-size) + 1)) $@ }
# select an [arg] by number
# (e.g `arg <number> echo`, or with explicit positioning `arg <number> echo ~~`)
function arg { [[ -n $1 && -n $2 ]] && { ARG="$(args-plain | sed -n "$1p" | sed 's/ *#.*//' | strip)"; [[ $(index_of ${(j: :)@} '~~') -eq 0 ]] && { echo_eval "${@:2} $ARG"; return 0 } || echo_eval ${${@:2}//~~/$ARG} } }
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
# select args within a rang[e]
# (e.g `e 2 5 echo`, or with explicit positioning `e 2 5 echo ~~ and ~~ again`)
function e { for i in $(seq $1 $2); do echo; arg $i ${${@:3}}; done }
# select all args via an iterator
# (e.g `each echo`, `all echo`, `map echo '$((~~ * 2))'`)
function each { ARGS_ROW_SIZE=$(args-list-size); for i in $(seq 1 $ARGS_ROW_SIZE); do echo; arg $i $@; done }
function all { ARGS_ROW_SIZE=$(args-list-size); for i in $(seq 1 $ARGS_ROW_SIZE); do echo; arg $i $@ &; done; wait }
function map { ARGS_ROW_SIZE=$(args-list-size); ARGS_MAP=''; for i in $(seq 1 $ARGS_ROW_SIZE); do echo; ARG=$(arg $i $@); echo $ARG; ARGS_MAP+="$ARG\n"; done; echo; echo $ARGS_MAP | ss }
# list / filter colum[n] by letter
# (e.g `n` to list all, `n d` to keep only the fourth column, delimited based on the bottom row)
function n { [[ $NN -eq 1 ]] && N=0 || N=1; [[ -z $1 ]] && { args-list; args-columns-bar $N } || { args-mark-references! $1 $N; _N=$N; args-select-column!; N=$_N; [[ $ARGS_PUSHED -eq 0 && $(index_of "$(args-columns $N)" b) -ne 0 ]] && args-columns-bar $N } }
# (`nn` is like `n`, but delimited based on the top row)
function nn { NN=1 n $@ }
# [c]opy into pasteboard
# (e.g `c` to copy all args, `11 c` to copy only the eleventh arg)
function c { [[ -z $1 ]] && args-plain | pbcopy || echo -n $@ | pbcopy }
# [y]ank / [p]ut current args into a different tab
function y { args > ~/.zshrc.args }
function p { echo "$(<~/.zshrc.args)" | ss }
# [u]ndo / [r]edo changes, up to `ARGS_HISTORY_MAX`
function u { ARG_SIZE_PREV=$(args-columns | strip); args-undo; args-list; args-undo-bar; ARG_SIZE_CURR=$(args-columns | strip); [[ -n $N && ${#ARG_SIZE_PREV} -lt ${#ARG_SIZE_CURR} ]] && args-columns-bar }
function r { args-redo; args-list; args-redo-bar }
# list / select historical args by [i]ndex
# (e.g `i` to list history, `i 8` to select the args at index 8)
function i { [[ -z $1 || $1 -lt $ARGS_TAIL || $1 -gt $ARGS_HEAD ]] && args-history || { ARGS_CURSOR=$1; a } }
# helpers
function args { echo $ARGS_HISTORY[$ARGS_CURSOR] }
function args-plain { args | no_color | expand }
function args-list { args | nl }
function args-list-plain { args | nl | no_color | expand }
function args-list-size { args | wc -l | awk '{print $1}' }
function args-columns { ARGS_COLUMNS=''; ARGS_COL_CURR=a; ARGS_SKIP_NL=1; args-pick-header! $@; for i in $(seq 1 ${#ARG}); do args-label-column! $i; done; echo $ARGS_COLUMNS }
function args-columns-bar { green-bg "$(args-columns $1)" }
# helpers! (`!` means the function sets env vars to be consumed by its caller)
function args-build-greps! { ARGS_FILTERS="grep ${*// / | grep }"; ARGS_FILTERS=${ARGS_FILTERS// -/ --invert-match }; ARGS_FILTERS=${ARGS_FILTERS//grep/grep --color=never --ignore-case}; ARGS_COLOR="egrep --color=always --ignore-case '${${@:#-*}// /|}'" }
function args-pick-header! { [[ -z ${1:-$ARGS_USE_BOTTOM_ROW} || ${1:-$ARGS_USE_BOTTOM_ROW} -eq 1 ]] && ARG=$(args-list-plain | tail -1) || ARG=$(args-list-plain | head -1) }
function args-label-column! { [[ $ARG[$1-1] == ' ' && $ARG[$1] != ' ' ]] && { [[ $ARGS_SKIP_NL -eq 1 ]] && { ARGS_SKIP_NL=0; ARGS_COLUMNS+=' ' } || { ARGS_COLUMNS+=$ARGS_COL_CURR; ARGS_COL_CURR=$(next_ascii $ARGS_COL_CURR) } } || ARGS_COLUMNS+=' ' }
function args-mark-references! { ARGS_USE_BOTTOM_ROW=$2; ARGS_COLUMNS=$(args-columns $2); ARGS_COL_FIRST=$(index_of $ARGS_COLUMNS a); ARGS_COL_TARGET=$(index_of $ARGS_COLUMNS $1); ARGS_COL_NEXT=$(index_of $ARGS_COLUMNS $(next_ascii $1)) }
function args-select-column! { args-list-plain | cut -c $([[ $ARGS_COL_TARGET -ne 0 ]] && echo $ARGS_COL_TARGET || echo $ARGS_COL_FIRST)-$([[ $ARGS_COL_NEXT -ne 0 ]] && echo $((ARGS_COL_NEXT - 1))) | strip_right | ss }
function args-get-new! { ARGS_NEW=$(cat - | head -1000 | no_empty); [[ -n $1 ]] && ARGS_NEW=$(echo $ARGS_NEW | insert_hash); ARGS_NEW_PLAIN=$(echo $ARGS_NEW | no_color | expand) }
function args-push-if-different! { [[ $ARGS_NEW_PLAIN != $(args-plain) ]] && { args-push $ARGS; ARGS_PUSHED=1; N= } || ARGS_PUSHED=0 }
# | after a list
function save_args { args-get-new! $1; [[ -n $ARGS_NEW ]] && { args-push-if-different!; args-replace $ARGS_NEW; args-list } }

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
function args-undo-bar { [[ $ARGS_UNDO_EXCEEDED -eq 1 ]] && { ARGS_UNDO_EXCEEDED=0; red-bg '  Reached the end of undo history  ' } }
function args-redo-bar { [[ $ARGS_REDO_EXCEEDED -eq 1 ]] && { ARGS_REDO_EXCEEDED=0; red-bg '  Reached the end of redo history  ' } }
function args-replace { ARGS_HISTORY[$ARGS_CURSOR]=$1 }
function args-increment { echo $(($1 % ARGS_HISTORY_MAX + 1)) }
function args-decrement { ARGS_DECREMENT=$(($ARGS_CURSOR - 1)); [[ $ARGS_DECREMENT -eq 0 ]] && ARGS_DECREMENT=$ARGS_HISTORY_MAX; echo $ARGS_DECREMENT }
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
function c1 { echo_eval 'export AWS_DEFAULT_REGION=eu-central-1' }
function e1 { echo_eval 'export AWS_DEFAULT_REGION=us-east-1' }
function e2 { echo_eval 'export AWS_DEFAULT_REGION=us-east-2' }
function w1 { echo_eval 'export AWS_DEFAULT_REGION=us-west-1' }
function w2 { echo_eval 'export AWS_DEFAULT_REGION=us-west-2' }
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
function cd- { CD=$(paste_when_empty $@); [[ -d $CD ]] && cd $CD || cd ${${CD}%/*} }
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

### Lis[t]
source "$ZSHRC_DIR/t.zsh"

### [O]pen
source "$ZSHRC_DIR/o.zsh"

### [K]ubectl
# TODO move to eof once stable
### Kubectl keymap
#  1   2   3   4   5  |  6   7   8   9   0
#             [p] [y] |  f  [g] [c] [r] [l]
#  a   o  [e]  u   i  | [d]  h   t   n  [s]
#     [q] [j] [k] [x] | [b]  m   w   v   z
# resources ref: g[r]ep / [s]ave / e[x]plain
function kr { cat ~/Documents/k8.txt | grep "$*" | ss }
function ks { kubectl api-resources > ~/Documents/k8.txt }
function kx { kubectl explain $@ }
# set [n]ame[s]pace
function kns { kubectl config set-context --current --namespace $@ }
# general
function k { kubectl $@ }
function kd { kubectl describe $@ }
function ke { kubectl exec $@ }
function kg { kubectl get $@ }
function kk { kubectl get $@ | ss }
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
function tf0 { echo_eval 'export TF_LOG=' }
function tf1 { echo_eval 'export TF_LOG=DEBUG' }
# [i]nit
function tfi { mkdir -p ~/.terraform.cache; terraform init $@ }
function tfiu { terraform init -upgrade }
function tfir { terraform init -reconfigure }
function tfim { terraform init -migrate-state }
# post `tfi`
# (e.g `tfp` to plan, `tfp iu` to init upgrade then plan)
function tfp { tf-pre $@ && terraform plan -out=tfplan }
function tfl { tf-pre $@ && terraform state list | sed "s/.*/'&'/" | ss }
function tfo { tf-pre $@ && terraform output }
function tfn { tf-pre $@ && terraform console }
function tfv { tf-pre $@ && terraform validate }
# post `tfp`
function tfa { terraform apply }
function tfd { terraform destroy }
function tfg { terraform show -no_color tfplan | sed 's/user_data.*/user_data [REDACTED]/' | gh gist create --web }
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
function d { [[ -n $1 ]] && { D=${${${@}#*://}%%/*}; [[ -z $D_UNDER_TEST ]] && dig +short $D | ss || echo "test output for\n$D" | ss } }
function f { [[ -n $1 ]] && f-pre $@ | sort | ss }
function l { ls -l | awk '{print $9}' | ss } # Not taking search pattern b/c folder matches break column alignment
function ll { ls -lA | awk '{print $9}' | egrep --color=never '^(\e\[3[0-9]m)?\.' | ss } # Show only hidden files
function w { which $@ | ss }
# doubles (they do not save into `args`)
function bb { pmset sleepnow }
function cc { eval $(prev_command) | no_color | ruby -e 'puts STDIN.read.strip' | pbcopy }
function dd { mkdir -p $DD_DUMP_DIR; dd-is-terminal-output && { DD=$(dd-dump-file); $(pbpaste > $DD); dd-taint-pasteboard; dd-clear-terminal } || dd-clear-terminal }
function ddd { mkdir -p $DD_DUMP_DIR; cd $DD_DUMP_DIR }
function ddc { rm -rf $DD_DUMP_DIR }
function ee { for i in $(seq $1 $2); do echo ${${@:3}//~~/$i}; done }
function eee { for i in $(seq $1 $2); do echo; echo_eval ${${@:3}//~~/$i}; done }
function ff { caffeinate }
function hh { diff --side-by-side --suppress-common-lines $1 $2 }
function ii { open -na 'IntelliJ IDEA CE.app' --args ${@:-.} }
function mm { mate ${@:-.} }
function oo { open ${@:-.} }
function pp { ruby ~/gh/jasonzhao6/sql_formatter.rb/run.rb $@ }
function tt { ~/gh/tt/tt.rb $@ }
function uu { diff --unified $1 $2 }
function xx { echo "bind '\"\\\e[A\": history-search-backward'\nbind '\"\\\e[B\": history-search-forward'" | pbcopy }
function yy { YY=$(prev_command); echo -n $YY | pbcopy }
# one-offs
function bif { brew install --formula $@ }
function flush { sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder }
function jcurl { curl --silent $1 | jq | { [[ -z $2 ]] && cat || grep -A${3:-0} -B${3:-0} $2 } }
function ren { for file in *$1*; do mv "$file" "${file//$1/$2}"; done }
# helpers
function echo_eval { echo $@ >&2; eval $@ }
function ellipsize { [[ ${#1} -gt $COLUMNS ]] && echo -n "${1:0:$((COLUMNS - 4))} \e[30m\e[47m...\e[0m" || echo $@ }
function has_internet { curl -s --max-time 1 http://www.google.com &> /dev/null }
function index_of { awk -v str1="$(echo $1 | no_color)" -v str2="$(echo $2 | no_color)" 'BEGIN { print index(str1, str2) }' }
function next_ascii { printf "%b" $(printf "\\$(printf "%o" $(($(printf "%d" "'$@") + 1)))") }
function paste_when_empty { echo ${@:-$(pbpaste)} }
function prev_command { fc -ln -1 }
# helper for `f`
function f-pre {
	[[ $@ == gh ]] && gh repo list $(org) --no-archived --limit 1000 --json name | jq -r '.[].name'
	[[ $@ == tf ]] && find ~+ -name main.tf | grep --invert-match '\.terraform' | sed "s|$HOME|~|g" | trim 0 8
}
# helpers for `dd`
function dd-init { DD_DUMP_DIR="$HOME/.zshrc.terminal-dump.d"; DD_CLEAR_TERMINAL=1 }; dd-init
function dd-is-terminal-output { [[ $(pbpaste | no_empty | strip | sed -n '$p') == \$* ]] }
function dd-dump-file { echo "$DD_DUMP_DIR/$(gdate +'%Y-%m-%d_%H.%M.%S.%6N').txt" }
function dd-taint-pasteboard { $(echo "$(pbpaste)\n\n(Dumped to '$DD')" | pbcopy) }
function dd-clear-terminal { [[ $DD_CLEAR_TERMINAL -eq 1 ]] && clear }
# | after strings
function extract_urls { pcregrep --only-matching '\b(?:https?:\/\/)(?:www\.)?[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,6}(?:\/[^\s?#]*)?(?:\?[^\s#]*)?(?:#[^\s]*)?\b' }
function hex { hexdump -C }
function no_color { sed -E 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g' }
function no_empty { sed '/^$/d' }
function strip { strip_left | strip_right }
function strip_left { sed 's/^[[:space:]]*//' }
function strip_right { sed 's/[[:space:]]*$//' }
function trim { no_color | cut -c $(($1 + 1))- | { [[ -z $2 ]] && cat || rev | cut -c $(($2 + 1))- | rev } }
# | after columns
function insert_hash { awk 'NF >= 2 {col_2_index = index($0, $2); col_1 = substr($0, 1, col_2_index - 1); col_rest = substr($0, col_2_index); printf "%s# %s\n", col_1, col_rest} NF < 2 {print}' }
function size_of { awk "{if (length(\$${1:-0}) > max_len) max_len = length(\$${1:-0})} END {print max_len}" }
# | after json
function keys { jq keys | trim_list | ss }
function trim_list { sed -e 's/^\[//' -e 's/^]//' -e 's/^ *"//' -e 's/",\{0,1\}$//' | no_empty }

### [Z]shrc
# source / test
[[ -z $UNDER_TEST && -f ~/.zshrc.secrets ]] && source ~/.zshrc.secrets
function z { source ~/.zshrc }
function zz { zsh $ZSHRC_DIR/_tests.zsh $@ }
# edit
function zm { mate $ZSHRC_DIR }
function zs { mate ~/.zshrc.secrets }
# [u]pload / [d]ownload other dotfiles
function zu {
    cp ~/.colordiffrc $ZSHRC_DIR/colordiffrc.txt
    cp ~/.gitignore $ZSHRC_DIR/gitignore.txt
    cp ~/.terraformrc $ZSHRC_DIR/terraformrc.txt
    cp ~/.tm_properties $ZSHRC_DIR/tm_properties.txt

    if [[ -f ~/.zshrc.secrets ]]; then
        openssl sha1 ~/.zshrc.secrets > ~/.zshrc.secrets_sha1_candidate
        diff ~/.zshrc.secrets_sha1_candidate ~/.zshrc.secrets_sha1 > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            cp ~/.zshrc.secrets_sha1_candidate ~/.zshrc.secrets_sha1
            cp ~/.zshrc.secrets ~/Downloads/\>\ Archive/zsh/.zshrc.secrets/$(date +'%y.%m.%d').txt
        fi
    fi
}
function zd {
    cp $ZSHRC_DIR/colordiffrc.txt ~/.colordiffrc
    cp $ZSHRC_DIR/gitignore.txt ~/.gitignore
    cp $ZSHRC_DIR/terraformrc.txt ~/.terraformrc
    cp $ZSHRC_DIR/tm_properties.txt ~/.tm_properties
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

### Keymap annotations
#  ::  -->  subsequent command
#  |   -->  alternative command
#  ~   -->  repeatable command
#  ()  -->  order of precedence
#  ,   -->  argument separator
#  ?   -->  optional command / argument
#  #   -->  number argument
#  _   -->  letter argument
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
# (1) (2) (3) (4) (5) | (6) (7) (8) (9) (0)   <--   s|ss|v|vv::a|n   a,*?,-*?::~?::#   (n|nn),_?::#
#             (p) (y) | [f] [g] (c) (r) [l]   <--   #|aa|each|all|map,*,~~?   e,#,#,*,~~?   #?,c::%+v
# (a) [o] (e) (u) (i) | [d] [h] [t] (n) (s)   <--   y::p   u|r::~?   i::i,#   d|f|h|w|kk|l|ll::a
#     {q} {j} [k]  x  |  b   m  [w] (v) [z]   <--   z|zz

### Doubles keymap
# () means defined for `args`
# [] means defined in this file
# {} means defined in secrets file
# (1)  2   3   4   5  |  6   7   8   9   0
#             [p] [y] | [f] [g] [c]  r  [l]   <--   pp,""?,*?::cc   yy|cc|xx::%+v   ff|bb   l|ll::a
# (a) [o] [e] [u] [i] | [d] [h] [t] (n) (s)   <--   oo|ii|mm   ee,#,#,*,~~::eee   uu|hh   dd::ddd|ddc
#     {q} {j} [k] [x] | [b] [m]  w  (v) [z]   <--   qq|q2::q   jj::#,j
