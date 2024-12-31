### Colors
# config
export GREP_COLOR='1;32'
export LSCOLORS='gxcxbxexfxegedabagaced'
export JQ_COLORS='1;35:1;35:1;35:1;35:1;32:1;33:1;33:1;36' # v1.7+
# modes
function bw { # black & white
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
}; color # set color aliases ahead of function definitions, so they can expand
# helpers (background)
function red-bg { echo "\e[41m$@\e[0m" }
function green-bg { echo "\e[42m$@\e[0m" }
# helpers (foreground)
function grep-highlighting { echo "\e[1;32m\e[K$@\e[m\e[K" }

### [Args]
# [s]ave args
function s { ss 'insert `#` after the first column to soft-select it' }
function ss { [[ -t 0 ]] && { eval $(prev-command) | save-args $@ } || save-args $@ }
# show / filter [a]rgs
function a { [[ -z $1 ]] && args-list || { args-build-greps! $@; args-plain | eval "$ARGS_FILTER | $ARGS_HIGHLIGHT" | save-args } }
# select [arg] by number
function arg { [[ -n $1 && -n $2 ]] && { ARG=$(args-plain | sed -n "$1p"); [[ $(index-of ${(j: :)@} '~~') -eq 0 ]] && echo-eval "${@:2} $ARG" || echo-eval ${${@:2}//~~/$ARG} } }
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
# select [r]andom
function rr { arg $((RANDOM % $(args-list-size) + 1)) $@ }
# select in rang[e]
function e { for i in $(seq $1 $2); do echo; arg $i ${${@:3}}; done }
# select with iterator
function each { ARGS_ROW_SIZE=$(args-list-size); for i in $(seq 1 $ARGS_ROW_SIZE); do echo; arg $i $@; done }
function all { ARGS_ROW_SIZE=$(args-list-size); for i in $(seq 1 $ARGS_ROW_SIZE); do echo; arg $i $@ &; done; wait }
function map { ARGS_ROW_SIZE=$(args-list-size); ARGS_MAP=''; for i in $(seq 1 $ARGS_ROW_SIZE); do echo; ARG=$(arg $i $@); echo $ARG; ARGS_MAP+="$ARG\n"; done; echo; echo $ARGS_MAP | save-args }
# select colum[n] via bottom row
function n { [[ $NN -eq 1 ]] && N=0 || N=1; [[ -z $1 ]] && { args-list; args-columns-bar $N } || { args-mark-references! $1 $N; args-select-column!; [[ $ARGS_PUSHED -eq 0 && $(index-of "$(args-columns $N)" b) -ne 0 ]] && args-columns-bar $N }; return 0 }
# select colum[n] via headers row
function nn { NN=1 n $@ }
# select first column
function aa { [[ -z $N || $N -eq 1 ]] && n a || nn a }
# [u]ndo \ [r]edo row / column selections
function u { ARG_SIZE_PREV=$(args-columns | strip); args-undo; args-list; args-undo-bar; ARG_SIZE_CURR=$(args-columns | strip); [[ ${#ARG_SIZE_PREV} -lt ${#ARG_SIZE_CURR} ]] && args-columns-bar }
function r { args-redo; args-list; args-redo-bar }
# [c]opy / paste via clipboard
# TODO which l; ss; 3 c is broken, need to escape string
function c { [[ -z $1 ]] && args-plain | pbcopy || echo -n $@ | pbcopy }
function v { pbpaste | save-args }
# [y]ank / [p]ut across tabs
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
# helpers (`!` means it sets env vars to be used by its caller function)
function args-build-greps! { ARGS_FILTER="grep ${*// / | grep }"; ARGS_FILTER=${ARGS_FILTER// -/ --invert-match }; ARGS_FILTER=${ARGS_FILTER//grep/grep --color=never --ignore-case}; ARGS_HIGHLIGHT="egrep --color=always --ignore-case '${${@:#-*}// /|}'" }
function args-label-column! { [[ ${ARG[$1-1]} == ' ' && ${ARG[$1]} != ' ' ]] && { [[ $ARGS_SKIP_NL -eq 1 ]] && { ARGS_SKIP_NL=0; ARGS_COLUMNS+=' ' } || { ARGS_COLUMNS+=$ARGS_COL_CURR; ARGS_COL_CURR=$(next-ascii $ARGS_COL_CURR) } } || ARGS_COLUMNS+=' ' }
function args-mark-references! { ARGS_COLUMNS=$(args-columns $2); ARGS_COL_FIRST=$(index-of $ARGS_COLUMNS a); ARGS_COL_TARGET=$(index-of $ARGS_COLUMNS $1); ARGS_COL_NEXT=$(index-of $ARGS_COLUMNS $(next-ascii $1)); ARGS_BOTTOM_ROW=$2 }
function args-select-column! { args-list-plain | cut -c $([[ $ARGS_COL_TARGET -ne 0 ]] && echo $ARGS_COL_TARGET || echo $ARGS_COL_FIRST)-$([[ $ARGS_COL_NEXT -ne 0 ]] && echo $((ARGS_COL_NEXT - 1))) | strip | save-args }
function args-get-new! { ARGS_NEW=$(cat - | head -1000 | no-empty | strip); [[ -n $1 ]] && ARGS_NEW=$(echo $ARGS_NEW | insert-hash); ARGS_NEW_PLAIN=$(echo $ARGS_NEW | no-color | expand) }
function args-push-if-different! { [[ $ARGS_NEW_PLAIN != $(args-plain) ]] && { args-push $ARGS; ARGS_PUSHED=1 } || ARGS_PUSHED=0 }
# |
function save-args { args-get-new! $1; [[ -n $ARGS_NEW ]] && { args-push-if-different!; args-replace $ARGS_NEW; args-list } } # always replace in case grep highlighting has updated

### Args history helpers
#
#             123456789
#  cursor     ^
#  head       ^
#  tail       ^
#
# array size is fixed, wrap at the end
# advance cursor and head together
# if next is tail, push tail forward
# to undo, only cursor moves, up to tail
# to redo, only cursor moves, up to head
function args-init { ARGS_HISTORY_MAX=100; ARGS_HISTORY=(); ARGS_CURSOR=0; ARGS_HEAD=0; ARGS_TAIL=0 }; args-init;
function args-push { ARGS_CURSOR=$(args-increment $ARGS_CURSOR); ARGS_HISTORY[$ARGS_CURSOR]=$1; ARGS_HEAD=$ARGS_CURSOR; [[ $ARGS_CURSOR -eq $ARGS_TAIL ]] && ARGS_TAIL=$(args-increment $ARGS_TAIL); [[ $ARGS_TAIL -eq 0 ]] && ARGS_TAIL=1 }
function args-undo { ARGS_PREV=$(args-decrement $ARGS_CURSOR); [[ $ARGS_CURSOR -ne $ARGS_TAIL ]] && ARGS_CURSOR=$ARGS_PREV || ARGS_UNDO_EXCEEDED=1 }
function args-redo { ARGS_NEXT=$(args-increment $ARGS_CURSOR); [[ $ARGS_CURSOR -ne $ARGS_HEAD ]] && ARGS_CURSOR=$ARGS_NEXT || ARGS_REDO_EXCEEDED=1 }
function args-undo-bar { [[ $ARGS_UNDO_EXCEEDED -eq 1 ]] && { ARGS_UNDO_EXCEEDED=0; red-bg 'Reached the end of undo history' } }
function args-redo-bar { [[ $ARGS_REDO_EXCEEDED -eq 1 ]] && { ARGS_REDO_EXCEEDED=0; red-bg 'Reached the end of redo history' } }
function args-replace { ARGS_HISTORY[$ARGS_CURSOR]=$1 }
function args-increment { echo $(($1 % ARGS_HISTORY_MAX + 1)) }
function args-decrement { ARGS_DECREMENT=$(($ARGS_CURSOR - 1)); [[ $ARGS_DECREMENT -eq 0 ]] && ARGS_DECREMENT=$ARGS_HISTORY_MAX; echo $ARGS_DECREMENT }
# debug
function args-history { echo $ARGS_HISTORY; echo -n $ARGS_CURSOR; echo -n $ARGS_HEAD; echo $ARGS_TAIL }

### AWS
# regions
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-'us-east-1'}
function c1 { echo-eval 'export AWS_DEFAULT_REGION=eu-central-1' }
function e1 { echo-eval 'export AWS_DEFAULT_REGION=us-east-1' }
function e2 { echo-eval 'export AWS_DEFAULT_REGION=us-east-2' }
function w1 { echo-eval 'export AWS_DEFAULT_REGION=us-west-1' }
function w2 { echo-eval 'export AWS_DEFAULT_REGION=us-west-2' }
# open [ec2] page
function ec2 { open "https://us-east-1.console.aws.amazon.com/ec2/home?region=$(echo $AWS_DEFAULT_REGION)#InstanceDetails:instanceId=$(ec2-id $@)" }
# ec2 [pre]fix search
function asg { ec2-args "Name=tag:aws:autoscaling:groupName, Values=$@*" }
function pre { ec2-args "Name=tag:Name, Values=$@*" }
# ec2 ssh via [ssm]
function ssm {
    aws ssm start-session \
        --document-name 'AWS-StartInteractiveCommand' \
        --parameters '{"command": ["sudo -i"]}' \
        --target $(ec2-id $@)
}
function ssm_ { aws ssm start-session --target $(ec2-id $@) }
function ssm-cmd {
    aws ssm start-session \
        --document-name 'AWS-StartNonInteractiveCommand' \
        --parameters "{\"command\": [\"${(j: :)@[1,-2]}\"]}" \
        --target $(ec2-id $@[-1]) \
    | pcregrep --multiline --ignore-case --invert-match "(Starting|\nExiting) session with SessionId: [a-z0-9-@\.]+(\n\n)*"
}
# [p]arameter [s]tore
function psg { PSG=$(aws ssm get-parameter --name $1 $([[ -n $2 ]] && echo --version $2) --query Parameter.Value --output text); [[ $PSG == {*} ]] && echo $PSG | jq || echo $PSG }
# [s]ecrets [m]anager
function smg { SMG=$(aws secretsmanager get-secret-value --secret-id $1 $([[ -n $2 ]] && echo --version-id $2) --query SecretString --output text); [[ $SMG == {*} ]] && echo $SMG | jq || echo $SMG }
function smd { aws secretsmanager delete-secret --secret-id $@ --force-delete-without-recovery }
# sts [decode]
function decode { aws sts decode-authorization-message --encoded-message $@ --output text | jq . }
# helpers
function ec2-args { aws ec2 describe-instances --filters $@ 'Name=instance-state-name, Values=running' --query "$(ec2-query)" --output text | sort --key=3 | sed 's/+00:00\t/Z  /g' | save-args }
function ec2-query { echo 'Reservations[].Instances[].[PrivateIpAddress, LaunchTime, Tags[?Key==`Name` || Key==`aws:autoscaling:groupName`].Value|[0]]' }
function ec2-id { [[ $@ =~ ^(i-)?[a-z0-9]{17}$ ]] && { [[ $@ =~ ^i-.*$ ]] && echo $@ || echo i-$@ } || { [[ $@ =~ ^[0-9\.]+$ ]] && ip-id $@ || name-id $@ } }
function id-name { aws ec2 describe-instances --filters "Name=instance-id, Values=$@" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text }
function ip-id { aws ec2 describe-instances --filters "Name=private-ip-address, Values=$@" --query 'Reservations[].Instances[].InstanceId' --output text }
function name-id { aws ec2 describe-instances --filters "Name=tag:Name, Values=$@" --query 'Reservations[].Instances[].InstanceId' --output text }

### [C]hange [d]ir
# go up
function .. { cd .. }
function ... { cd ../.. }
function .... { cd ../../.. }
function ..... { cd ../../../.. }
function ...... { cd ../../../../.. }
function ....... { cd ../../../../../.. }
function ........ { cd ../../../../../../.. }
function ......... { cd ../../../../../../../.. }
function .......... { cd ../../../../../../../../.. }
# go to <pasteboard>
function cd- { CD=$(paste-if-empty $@); [[ -d $CD ]] && cd $CD || cd ${${CD}%/*} }
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
# g[i]t status
function gi { git status }
# [d]iff
function gd { git diff }
# [s]tash
function gs { git add --all; git stash save $@ }
# post stash
function ga { git stash apply "stash@{${@:-0}}" }
function gc { git stash clear }
function gl { git stash list --pretty=format:'%C(yellow)%gd %C(magenta)%as %C(green)%s' }
# [u]ndo and discard
function gu { git reset --soft HEAD~$@ }
function gz { git add --all; git reset --hard; gi }
function guz { gu $@; gz }
# [b]ranch
function gb { GB=$(gb-merged); [[ $GB ]] && GB="\n----------------\n$GB"; echo "$(git branch)$GB" | save-args }
function gbb { gb-merged | xargs git branch --delete; git remote prune origin; echo; gb }
function gbd { git branch --delete --force $@; git push origin --delete $@; gb }
# [g]it checkout
function g { git checkout $@ }
function gg { git checkout main || git checkout master; git pull; git status }
function gn { gg; git checkout -b $@ }
# commit
function ge { git commit --allow-empty -m 're-run: Empty commit to trigger build' }
function gm { git add --all; git commit --amend --no-edit }
function gw { git add --all; git commit --amend }
function gv { git add --all; git commit }
function gy { git cherry-pick $@ }
# g[r]ep
function gr { GR_GREPS="--grep='${*// /' --grep='}'"; eval "git log ${1:+--all} $GR_FIRST_PARENT $GR_GREPS --all-match --extended-regexp --regexp-ignore-case --pretty=format:\"%C(yellow)%h %C(magenta)%as %C(green)'%s' %C(cyan)%an\"" }
function grr { GR_FIRST_PARENT=--first-parent gr $@ }
# rebase
function gx { git add --all; git commit --fixup $@ }
function gxx { gxx-pre! $@; [[ -n $GXX_HEAD_NUM ]] && gxx-head-num || gxx-main-branch }
# rebase conflict
function gxa { git rebase --abort }
function gxc { git add --all; git rebase --continue }
# [p]ush / [P]ull
function gf { git push --force }
function gp { git push }
function gP { git pull $@ }
# helpers (gb)
function gb-merged { git branch --merged | grep --invert-match 'main$' | grep --invert-match 'master$' | grep --invert-match '^\*' }
# helpers (gxx)
function gxx-main-branch { git fetch $GXX_REMOTE $GXX_BRANCH && git rebase --interactive --autosquash $GXX_REMOTE/$GXX_BRANCH }
function gxx-head-num { git rebase --interactive --autosquash HEAD~$(($GXX_HEAD_NUM + 1)) } # `+ 1` to cover the `fixup!` commit
function gxx-pre! { # (`!` means it sets env vars to be used by its caller function)
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
# open tab
function main { open https://$(domain)/$(org)/$(repo) }
function new { gp && gh pr create --fill && gh pr view --web }
function pr { open https://$(domain)/$(org)/$(repo)/pull/$@ }
function prs { open "https://$(domain)/pulls?q=is:open+is:pr+user:$(org)" }
function sha { open https://$(domain)/$(org)/$(repo)/commit/$@ }
function repos { gh repo list $(org) --no-archived --limit 1000 --json name | jq -r '.[].name' | sort | save-args }
# helpers
function branch { git rev-parse --abbrev-ref HEAD }
function domain { git remote get-url origin | sed 's/.*[:/]\([^/]*\)\/.*\/.*/\1/' }
function org { git remote get-url origin | sed 's/.*[:/]\([^/]*\)\/.*/\1/' }
function repo { git rev-parse --show-toplevel | xargs basename }

### [K]ubectl
# TODO move to eof once stable
### Kubectl keymap
#  1   2   3   4   5  |  6   7   8   9   0
#             [p] [y] |  f  [g] [c] [r] [l]
#  a   o  [e]  u   i  | [d]  h   t   n  [s]
#     [q] [j] [k] [x] | [b]  m   w   v   z
# help: g[r]ep / [s]ave / e[x]plain
function kr { cat ~/Documents/k8.txt | grep "$*" | save-args }
function ks { kubectl api-resources > ~/Documents/k8.txt }
function kx { kubectl explain $@ }
# [n]ame[s]pace
function kns { kubectl config set-context --current --namespace $@ }
# general
function k { kubectl $@ }
function kd { kubectl describe $@ }
function ke { kubectl exec $@ }
function kg { kubectl get $@ }
function kk { kubectl get $@ | save-args }
function kl { kubectl logs $@ }
function kp { kubectl port-forward $@ }
# exec shortcuts
function kb { kubectl exec -it $@ -- bash }
function kc { kubectl exec $@[-1] -- $@[1,-2] }
# get as [j]son / [y]aml
function kj { [[ -n $1 ]] && kubectl get $@ -o json > ~/Documents/k8.json | jq }
function kjj { cat ~/Documents/k8.json }
function ky { [[ -n $1 ]] && kubectl get $@ -o yaml > ~/Documents/k8.yaml | cat }
function kyy { cat ~/Documents/k8.yaml }
# [q]uery json output
function kq { jq ${@:-.} ~/Documents/k8.json }

### [T]erra[f]orm
# config
function tf0 { echo-eval 'export TF_LOG=' }
function tf1 { echo-eval 'export TF_LOG=DEBUG' }
# [c]lean
function tfc { rm -rf tfplan .terraform ~/.terraform.d }
function tfcc { rm -rf tfplan .terraform ~/.terraform.d ~/.terraform.cache; mkdir -p ~/.terraform.cache }
# debug
function tf { pushd ~/gh/scratch/tf-debug > /dev/null; [[ -z $1 ]] && terraform console || echo "local.$@" | terraform console; popd > /dev/null }
# find
function tfw { find ~+ -name main.tf | grep --invert-match '\.terraform' | sed "s|$HOME|~|g" | sort | trim 0 8 | save-args }
# [f]ormat
function tff { terraform fmt -recursive $@ }
# [i]nit
function tfi { terraform init $@ }
function tfim { terraform init -migrate-state }
function tfir { terraform init -reconfigure }
function tfiu { terraform init -upgrade }
# post init
function tfa { tf-pre $@ && terraform apply }
function tfd { tf-pre $@ && terraform destroy }
function tfl { tf-pre $@ && terraform state list | sed "s/.*/'&'/" | save-args }
function tfn { tf-pre $@ && terraform console }
function tfo { tf-pre $@ && terraform output }
function tfp { tf-pre $@ && terraform plan -out=tfplan }
function tfv { tf-pre $@ && terraform validate }
function tfx { tf-pre $@ && terraform apply -refresh-only }
# post list
function tfm { terraform state mv $1 $2 }
function tfr { terraform state rm $@ }
function tfs { terraform state show $@ }
function tft { terraform taint $@ }
function tfu { terraform untaint $@ }
# post plan
function tfg { terraform show -no-color tfplan | sed 's/user_data.*/user_data [REDACTED]/' | gh gist create --web }
function tfz { terraform force-unlock $@ }
# non-prod
function tfaa { tf-pre $@ && terraform apply -auto-approve }
# helpers
function tf-pre {
    [[ -z $1 ]] && return

    for var in $@; do
        case $var in
            e) tfe;;
            i) tfi;;
            im) tfim;;
            ir) tfir;;
            iu) tfiu;;
        esac
    done
}

### Util
# singles (uses `args`)
function d { [[ -n $1 ]] && dig +short ${${${@}#*://}%%/*} | save-args }
function f { echo } # TODO find tf files and gh repos
function l { ls -l | awk '{print $9}' | save-args }
# doubles
function bb { pmset sleepnow }
function cc { eval $(prev-command) | no-color | ruby -e 'puts STDIN.read.strip' | pbcopy }
function dd { clear } # TODO dump pasteboard to file if looks like termal output, then clear screen
function ee { for i in $(seq $1 $2); do echo ${${@:3}//~~/$i}; done }
function eee { for i in $(seq $1 $2); do echo; echo-eval ${${@:3}//~~/$i}; done }
function ff { caffeinate }
function hh { diff --side-by-side --suppress-common-lines $1 $2 }
function ii { open -na 'IntelliJ IDEA CE.app' --args ${@:-.} }
function ll { ls -la | awk '{print $9}' | save-args } # TODO dry
function mm { mate ${@:-.} }
function oo { open ${@:-.} }
function pp { ruby ~/gh/jasonzhao6/sql_formatter.rb/run.rb $@ }
function tt { ~/gh/tt/tt.rb $@ }
function uu { diff --unified $1 $2 }
function vv { echo } # TODO view dumped files
function xx { echo "bind '\"\\\e[A\": history-search-backward'\nbind '\"\\\e[B\": history-search-forward'" | pbcopy }
function yy { YY=$(prev-command); echo -n $YY | pbcopy }
# misc
function bif { brew install --formula $@ }
function flush { sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder }
function jcurl { curl --silent $1 | jq | { [[ -z $2 ]] && cat || grep -A${3:-0} -B${3:-0} $2 } }
function ren { for file in *$1*; do mv "$file" "${file//$1/$2}"; done }
# helpers
function echo-eval { echo $@ >&2; eval $@ }
function ellipsize { [[ ${#1} -gt $COLUMNS ]] && echo -n "${1:0:$((COLUMNS - 4))} \e[30m\e[47m...\e[0m" || echo $@ }
function index-of { awk -v str1="$(echo $1 | no-color)" -v str2="$(echo $2 | no-color)" 'BEGIN { print index(str1, str2) }' }
function next-ascii { printf "%b" $(printf "\\$(printf "%o" $(($(printf "%d" "'$@") + 1)))") }
function paste-if-empty { echo ${@:-$(pbpaste)} }
function prev-command { fc -ln -1 }
# | (after strings)
function hex { hexdump -C }
function no-color { sed -E 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g' }
function no-empty { sed '/^$/d' }
function strip { sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' }
function trim { no-color | cut -c $(($1 + 1))- | { [[ -z $2 ]] && cat || rev | cut -c $(($2 + 1))- | rev } }
# | (after columns)
function insert-hash { awk 'NF >= 2 {col_2_index = index($0, $2); col_1 = substr($0, 1, col_2_index - 1); col_rest = substr($0, col_2_index); printf "%s# %s\n", col_1, col_rest} NF < 2 {print}' }
function length-of { awk "{if (length(\$${1:-1}) > max_len) max_len = length(\$${1:-1})} END {print max_len}" }
# | (after json)
function keys { jq keys | trim-list | save-args }
function trim-list { sed -e 's/^\[//' -e 's/^]//' -e 's/^ *"//' -e 's/",\{0,1\}$//' | no-empty }

### [Z]sh rc
# edit
function zm { mate ~/gh/dotfiles/zshrc.zsh }
function zs { mate ~/.zshrc.secrets }
# [t]est
function zt { zsh ~/gh/dotfiles/zshrc-tests.zsh }
# save
function zz {
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

    source ~/.zshrc
}
[ -f ~/.zshrc.secrets ] && source ~/.zshrc.secrets
# lo[a]d
function za {
    cp ~/gh/dotfiles/colordiffrc.txt ~/.colordiffrc
    cp ~/gh/dotfiles/gitignore.txt ~/.gitignore
    cp ~/gh/dotfiles/terraformrc.txt ~/.terraformrc
    cp ~/gh/dotfiles/tm_properties.txt ~/.tm_properties

    mkdir -p ~/.terraform.cache

    source ~/.zshrc
}

### Zsh arrow keys
# history search (up-down)
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end
# word separators (left-right)
WORDCHARS=${WORDCHARS/\.} # exclude .
WORDCHARS=${WORDCHARS/\/} # exclude /
WORDCHARS=${WORDCHARS/\=} # exclude =
WORDCHARS+='|'

### Zsh [h]istory
# config
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
# grep
function h { egrep --ignore-case "$*" ~/.zsh_history | trim 15 | sort --unique | save-args }
# [c]lean
function hc { rm ~/.zsh_history }
# edit
function hm { mate ~/.zsh_history }
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
function sts-info { [[ -n $(aws-profile) ]] && { set-sts-info; echo " $(<~/$STS_INFO_DIR/$(aws-profile))" } }
function tf-info { [[ -n $TF_VAR_datadog_api_key ]] && echo ' TF_VAR' }
# helpers (sts-info)
STS_INFO_DIR='.zshrc.sts-info.d'
function reset-sts-info { rm -rf ~/$STS_INFO_DIR }
function set-sts-info { [[ ! -e ~/$STS_INFO_DIR/$(aws-profile) ]] && { mkdir -p ~/$STS_INFO_DIR; echo "$(account)::$(role)" > ~/$STS_INFO_DIR/$(aws-profile) } }
function account { aws iam list-account-aliases --query 'AccountAliases[0]' --output text }
function aws-key { [[ -n $AWS_ACCESS_KEY_ID ]] && echo $AWS_ACCESS_KEY_ID }
function aws-profile { { [[ -n $AWS_PROFILE ]] && echo $AWS_PROFILE } }
function role { ROLE=$(aws sts get-caller-identity --query Arn --output text | awk -F'/' '{print $2}'); [[ $ROLE == *_* ]] && echo $ROLE | awk -F'_' '{print $2}' || echo $ROLE }

### Keymap annotations
#  :   -->  subsequent command
#  |   -->  similar commands
#  #   -->  a number
#  .   -->  a letter
#  +   -->  a keyboard shortcut
#  %   -->  mac's command key
#  ()  -->  a group of args
#  ?   -->  an optinoal arg
#  *   -->  an arbitrary arg
#  ~~  -->  an arg placeholder
#  ""  -->  wrap arg in quotes

### Git keymap
# [] means defined in this file
# <> means already taken, e.g `go`
# [1]  2   3   4   5  |  6   7   8   9  [0]    <--    g1|g0
#             [p] [y] | [f] [g] [c] [r] [l]    <--    gp|gP|gf  gg|gb|gn|(g *)  ((gr|gr-) *?):ss|s  gl|(gs *?)|(ga #?)|gc
# [a] <o> [e] [u] [i] | [d] <h> [t] [n] [s]    <--    ge|(gx *)|gm|gw|gv  ((gu|gz|guz) #?)  gi|gd  gt|gtv|gta|gtr
#      q   j   k  [x] | [b] [m] [w] [v] [z]    <--    (gxx (u|m|#)?):gxa|gxc  gb:(# (g|gbb|gbd))

### Terraform keymap
# [] means defined in this file
# {} means defined in secrets file
# [1]  2   3   4   5  |  6   7   8   9  [0]    <--    tf1|tf0
#             [p]  y  | [f] [g] [c] [r] [l]    <--    tfp:tfa|tfg|tfz  tff:tfv  tfc|tfcc  tfl:tft|tfu|tfs|tfm|tfr
# [a] [o] {e} [u] [i] | [d]  h  [t] [n] [s]    <--    tfa|tfa-|tfo|tfd|tfx  tfi|tfiu|tfir|tfim  tfn|tf
#      q   j   k  [x] |  b  [m] [w] [v] [z]    <--    tfw:aa|(# cd)

### Singles keymap
# () means defined for args
# [] means defined in this file
# {} means defined in secrets file
# TODO redo annotations x2
# (1) (2) (3) (4) (5) | (6) (7) (8) (9) (0)    <--    ((#|r|each\all\map) * ~~?)
#             (p) (y) | [f] [g] (c) (r) [l]    <--    (f ""? *?):cc  (#? c):%+v  l:(# c)
# (a) {o} (e) (u)  i  | [d] [h]  t  (n) (s)    <--    a:aa|rr  (e # # * ~~?)  s|s-:aa|nn
#     {q} {j} [k]  x  |  b   m  {w} (v)  z     <--    x:%+v

### Doubles keymap
# () means defined for args
# [] means defined in this file
# {} means defined in secrets file
# (1)  2   3   4   5  |  6   7   8   9   0        /   yy:pp  ff|bb  cc:%+v  rr:aa|nn|rr  ll:aa
#             [p] [y] | [f] [g] [c] (r) [l]    <--    (aa #?):aa|nn|rr  ((nn|nnn) .?)|a:aa|rr  ss|vv:aa|nn
# (a) [o] [e] [u] [i] | [d] [h] [t] (n) (s)    <--    oo|ii|mm  (ee # # * ~~):eee  uu|hh  dd:aa
#     {q} {j} [k] [x] | [b] [m] {w} [v] [z]    <--    qq|q2:q  jj:j|aa  kk:aa|nn  xx:%+v  ww:w|aa  zz|zt
