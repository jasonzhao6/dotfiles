OTHER_NAMESPACE='other_keymap'
OTHER_ALIAS='o'
OTHER_DOT="${OTHER_ALIAS}${KEYMAP_DOT}"

OTHER_KEYMAP=(
	"${OTHER_ALIAS} {url} # Open the specified url"
	"${OTHER_ALIAS} {path} # Open the specified path in Finder"
	"${OTHER_DOT}o # Open the current directory in Finder"
	"${OTHER_DOT}i # Open the current directory in IntelliJ IDEA"
	"${OTHER_DOT}i {path} # Open the specified path in IntelliJ IDEA"
	"${OTHER_DOT}m # Open the current directory in TextMate"
	"${OTHER_DOT}m {path} # Open the specified path in TextMate"
	''
	"${OTHER_DOT}cc # Copy the last command"
	"${OTHER_DOT}c # Copy the last output"
	"${OTHER_DOT}1 # Save the last output to \`1.txt\`"
	"${OTHER_DOT}2 # Save the last output to \`2.txt\`"
	"${OTHER_DOT}11 # Save pasteboard value to \`1.txt\`"
	"${OTHER_DOT}22 # Save pasteboard value to \`2.txt\`"
	"${OTHER_DOT}e # Open \`1.txt\` and \`2.txt\` in TextMate"
	"${OTHER_DOT}0 # Empty \`1.txt\` and \`2.txt\`"
	"${OTHER_DOT}u {file 1} {file 2} # Unified diff"
	"${OTHER_DOT}uu {file 1} {file 2} # Side-by-side diff"
	''
	"${OTHER_DOT}y # Alias for \`pbcopy\`"
	"${OTHER_DOT}p # Alias for \`pbpaste\`"
	''
	"${OTHER_DOT}k # Clear the terminal"
	"${OTHER_DOT}kk # Show archived terminal outputs"
	"${OTHER_DOT}kc # Clear archived terminal outputs"
	''
	"${OTHER_DOT}s # Sleep"
	"${OTHER_DOT}a # Stay awake"
	"${OTHER_DOT}n # Stay on task"
	''
	"${OTHER_DOT}d {url} # DNS dig"
	"${OTHER_DOT}df # DNS flush"
	"${OTHER_DOT}- {start} {finish} {~~} # Run a sequence of commands"
	"${OTHER_DOT}f # Format sql query from stdin"
	"${OTHER_DOT}f '{sql}' # Format sql query from cli arg"
	"${OTHER_DOT}j {url} {match} {num lines} # Curl a json endpoint"
	"${OTHER_DOT}r {before} {after} # Rename files in the current directory"
	"${OTHER_DOT}t {command} # Time command execution"
)

keymap_init $OTHER_NAMESPACE $OTHER_ALIAS "${OTHER_KEYMAP[@]}"

function other_keymap {
	# If the input is open-able, open it
	local input=$*
	[[ -n $input ]] && other_keymap_o "$input" && return

	keymap_show $OTHER_NAMESPACE $OTHER_ALIAS ${#OTHER_KEYMAP} "${OTHER_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

OTHER_KEYMAP_DEFAULT_DIFF_FILE_1="$HOME/Documents/1.txt"
OTHER_KEYMAP_DEFAULT_DIFF_FILE_2="$HOME/Documents/2.txt"

source "$ZSHRC_DIR/$OTHER_NAMESPACE/other_helpers.zsh"

function other_keymap_- {
	local start=$1; shift
	local finish=$1; shift # `end` is a reserved keyword
	local command=$*

	for number in $(seq "$start" "$finish"); do
		echo
		echo_eval "${command//~~/$number}"
	done
}

function other_keymap_0 {
	echo -n > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1"
	echo -n > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2"
}

function other_keymap_1 {
	# When invoked as standalone command
	if [[ -t 0 ]]; then
		eval "$(prev_command)" | bw > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1"

	# When invoked after a pipe `|`
	else
		bw > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1"
	fi
}

function other_keymap_11 {
	pbpaste > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1"
}

function other_keymap_2 {
	# When invoked as standalone command
	if [[ -t 0 ]]; then
		eval "$(prev_command)" | bw > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2"

	# When invoked after a pipe `|`
	else
		bw > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2"
	fi
}

function other_keymap_22 {
	pbpaste > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2"
}

function other_keymap_a {
	caffeinate
}

function other_keymap_c {
	echo -n "$(eval "$(prev_command)" | bw | ruby_strip)" | pbcopy
}

function other_keymap_cc {
	echo -n "$(prev_command)" | pbcopy
}

function other_keymap_d {
	local url=$*
	[[ -z "$1" ]] && return

	# Strip protocol and path
	local domain=${${${url}#*://}%%/*}

	if [[ -z $ZSHRC_UNDER_TESTING ]]; then
		dig +short $domain | args_keymap_s
	else
		printf "test output for\n%s" "$domain" | args_keymap_s
	fi
}

function other_keymap_df {
	sudo dscacheutil -flushcache
	sudo killall -HUP mDNSResponder
}

function other_keymap_e {
	mate "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1" "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2"
}

function other_keymap_f {
	local sql=$*

	# shellcheck disable=SC2086 # Empty quotes break Ruby's `gets` method
	ruby ~/github/jasonzhao6/sql_formatter.rb/run.rb $sql
}

function other_keymap_i {
	local target_path=${*:-.}

	open -na 'IntelliJ IDEA CE.app' --args "$target_path"
}

function other_keymap_j {
	local url=$1
	local match=$2
	local num_lines=${3:-0}

	[[ -z $url ]] && return

	curl --silent "$url" | jq | {
		if [[ -z "$match" ]]; then
			cat
		else
			grep --ignore-case -A"$num_lines" -B"$num_lines" "$match"
		fi
	}
}

function other_keymap_k {
	mkdir -p "$OTHER_KEYMAP_K_DIR"

	# If pasteboard contains terminal output looking text, archive it
	if [[ $(pbpaste | compact | strip | sed -n '$p') == \$* ]]; then
		local filename; filename="$OTHER_KEYMAP_K_DIR/$(gdate +'%Y-%m-%d_%H.%M.%S.%6N').txt"

		pbpaste > "$filename"

		# Taint the pasteboard, so that it doesn't get dumped again
		printf "%s\n\n(Dumped to '%s')" "$(pbpaste)" "$filename" | pbcopy
	fi

	[[ -z $ZSHRC_UNDER_TESTING ]] && clear
}

function other_keymap_kc {
	rm -rf "$OTHER_KEYMAP_K_DIR"
}

function other_keymap_kk {
	mkdir -p "$OTHER_KEYMAP_K_DIR"
	cd "$OTHER_KEYMAP_K_DIR" && nav_keymap_n || return
}

function other_keymap_m {
	local target_path=${*:-.}

	mate "$target_path"
}

function other_keymap_n {
	~/github/jasonzhao6/tt/tt.rb "$@"
}

function other_keymap_o {
	local target=$*

	# If target is empty, open the current directory
	[[ -z $target ]] && open . && return

	# If target is a local directory or file, open it
	[[ -d $target ]] && open "$target" && return
	[[ -f $target ]] && open "$target" && return

	# If target is a list of urls, open them
	local has_urls
	while IFS= read -r url; do
		[[ -z $url ]] && continue

		has_urls=1
		open "$url"
	done < <(echo "$target" | extract_urls | bw)
	[[ -n $has_urls ]] && return

	# If we didn't open anything, return exit code `1`
	return 1
}

function other_keymap_p {
	pbpaste
}

function other_keymap_r {
	local before=$1
	local after=$2

	[[ -z $before || -z $after ]] && return

	for file in *"$before"*; do
		mv "$file" "${file//$before/$after}"
	done
}

function other_keymap_s {
	pmset sleepnow
}

function other_keymap_t {
	local command=$*

	local start_time; start_time=$(gdate +%s.%2N)
	eval "$command"
	gray_fg "\nCommand executed in $(echo "$(gdate +%s.%2N) - $start_time" | bc) seconds"
}

function other_keymap_u {
	local file_1=${1:-$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1}
	local file_2=${2:-$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2}

	diff --unified "$file_1" "$file_2"
}

function other_keymap_uu {
	local file_1=${1:-$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1}
	local file_2=${2:-$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2}

	diff --side-by-side --suppress-common-lines "$file_1" "$file_2"
}

function other_keymap_y {
	pbcopy
}
