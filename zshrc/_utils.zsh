# TODO tidy up

# helpers
# shellcheck disable=SC2154
function caller { echo "${funcstack[3]}"; }
function callee { echo "${funcstack[2]}"; }
function echo_eval { echo "$@" >&2; eval "$@"; }
function ellipsize { [[ ${#1} -gt $COLUMNS ]] && echo -n "${1:0:$((COLUMNS - 4))} \e[30m\e[47m...\e[0m" || echo "$@"; }
function has_internet { curl -s --max-time 1 http://www.google.com &> /dev/null; }
function index_of { awk -v str1="$(echo "$1" | bw)" -v str2="$(echo "$2" | bw)" 'BEGIN { print index(str1, str2) }'; }
# shellcheck disable=SC2059
function next_ascii { printf "%b" "$(printf "\\$(printf "%o" $(($(printf "%d" "'$*") + 1)))")"; }
function paste_when_empty { echo "${@:-$(pbpaste)}"; }
function prev_command { fc -ln -1; }
# | after strings
function bw { sed -E 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g'; }
function compact { sed '/^$/d'; }
function contain { pgrep --only-matching ".*$*.*" | bw; }
function extract_urls { pgrep --only-matching '\b(?:https?:\/\/)(?:www\.)?[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,6}(?:\/[^\s?#]*)?(?:\?[^\s#]*)?(?:#[^\s]*)?\b'; }
function hex { hexdump -C; }
function strip { strip_left | strip_right; }
function strip_left { sed 's/^[[:space:]]*//'; }
function strip_right { sed 's/[[:space:]]*$//'; }
function trim { bw | cut -c $(($1 + 1))- | { [[ -z $2 ]] && cat || rev | cut -c $(($2 + 1))- | rev; }; }
# | after columns
function insert_hash { awk 'NF >= 2 {col_2_index = index($0, $2); col_1 = substr($0, 1, col_2_index - 1); col_rest = substr($0, col_2_index); printf "%s# %s\n", col_1, col_rest} NF < 2 {print}'; }
function size_of { awk "{if (length(\$${1:-0}) > max_len) max_len = length(\$${1:-0})} END {print max_len}"; }
# | after json
function keys { jq keys | trim_list | args_keymap_s; }
function trim_list { sed -e 's/^\[//' -e 's/^]//' -e 's/^ *"//' -e 's/",\{0,1\}$//' | compact; }
