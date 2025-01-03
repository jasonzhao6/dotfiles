# TODO

### Util
# singles (they save into `args`)
function d { [[ -n $1 ]] && { D=${${${@}#*://}%%/*}; [[ -z $ZSHRC_UNDER_TEST ]] && dig +short $D | ss || echo "test output for\n$D" | ss } }
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
