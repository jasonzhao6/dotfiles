OTHER_NAMESPACE='other_keymap'
OTHER_ALIAS='o'
OTHER_DOT="${OTHER_ALIAS}${KEYMAP_DOT}"

OTHER_KEYMAP=(
	"${OTHER_ALIAS} <path> # Open path in Finder"
	"${OTHER_ALIAS} <url> # Open url in browser"
	"${OTHER_DOT}o # Open current dir in Finder"
	"${OTHER_DOT}e <path>? # Open IntelliJ (Default: CWD)"
	"${OTHER_DOT}m <path>? # Open TextMate (Default: CWD)"
	''
	"${OTHER_DOT}a # Stay awake"
	"${OTHER_DOT}s # Sleep"
	''
	"${OTHER_DOT}cc # Copy command"
	"${OTHER_DOT}c # Copy output"
	"${OTHER_DOT}v # Speak pasteboard"
	"${OTHER_DOT}y # Alias for \`pbcopy\`"
	"${OTHER_DOT}p # Alias for \`pbpaste\`"
	''
	"${OTHER_DOT}1 ${KEYMAP_PIPE_PATTERN} # Save pasteboard value to \`diff.1.txt\`"
	"${OTHER_DOT}2 ${KEYMAP_PIPE_PATTERN} # Save pasteboard value to \`diff.2.txt\`"
	"${OTHER_DOT}u <file 1>? <file 2>? # Unified diff"
	"${OTHER_DOT}uu <file 1>? <file 2>? # Side by side diff"
	"${OTHER_DOT}12 # Open diff files in TextMate"
	"${OTHER_DOT}0 # Empty \`diff.1.txt\` and \`diff.2.txt\`"
	''
	"${OTHER_DOT}i <index> <file>? ${KEYMAP_PIPE_PATTERN} # CSV: Keep column by index"
	"${OTHER_DOT}id <index> <file>? ${KEYMAP_PIPE_PATTERN} # CSV: Delete column by index"
	"${OTHER_DOT}ii <index> <file>? ${KEYMAP_PIPE_PATTERN} # CSV: Sort lines by column"
	"${OTHER_DOT}ix <i1> <i2> <file>? ${KEYMAP_PIPE_PATTERN} # CSV: Swap columns"
	"${OTHER_DOT}x <file 1>? <file 2>? # CSV: Keep lines matching 1st column"
	"${OTHER_DOT}xx <file 1>? <file 2>? # CSV: Delete lines matching 1st column"
	''
	"${OTHER_DOT}t <command> # Time a command"
	"${OTHER_DOT}w <seconds>? <command> # Watch a command (Default: 1s)"
	"${OTHER_DOT}f <start> <finish> (~~) # Run a command sequence in foreground"
	"${OTHER_DOT}b <start> <finish> (~~) # Run a command sequence in background"
	''
	"${OTHER_DOT}k # Clear terminal"
	"${OTHER_DOT}kk # Show archived terminal outputs"
	"${OTHER_DOT}kc # Clear archived terminal outputs"
	''
	"${OTHER_DOT}8 # Use Java 8"
	"${OTHER_DOT}d <url>? # DNS dig (Default: Pasteboard)"
	"${OTHER_DOT}df # DNS flush"
	"${OTHER_DOT}j <url> <regex>? <num lines>? # Curl json endpoint"
	"${OTHER_DOT}n # Encrypt pasteboard + print decrypt cmd"
	"${OTHER_DOT}q '<sql>'? ${KEYMAP_PIPE_PATTERN} # Format a sql query (Default: Pasteboard)"
	"${OTHER_DOT}r <before> <after> # Rename files in current directory"
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

# Sources
source "$ZSHRC_SRC_DIR/$OTHER_NAMESPACE/other_helpers.zsh"

# Constants
OTHER_BACKGROUND_OUTPUTS_FILE="$ZSHRC_DATA_DIR/other.background-outputs.txt"
OTHER_KEYMAP_DEFAULT_DIFF_FILE_1="$ZSHRC_DATA_DIR/other.diff-1.txt"
OTHER_KEYMAP_DEFAULT_DIFF_FILE_2="$ZSHRC_DATA_DIR/other.diff-2.txt"

function other_keymap_0 {
	echo -n > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1"
	echo -n > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2"
}

function other_keymap_1 {
	# When invoked as standalone command
	if [[ -t 0 ]]; then
		pbpaste > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1"

	# When invoked after a pipe `|`
	else
		bw > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1"
	fi
}

function other_keymap_12 {
	mate "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1" "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2"
}

function other_keymap_2 {
	# When invoked as standalone command
	if [[ -t 0 ]]; then
		pbpaste > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2"

	# When invoked after a pipe `|`
	else
		bw > "$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2"
	fi
}

function other_keymap_8 {
	eval "$(jenv init -)"
	jenv shell 1.8
}

function other_keymap_a {
	caffeinate
}

function other_keymap_b {
	local start=$1; shift
	local finish=$1; shift # `end` is a reserved keyword
	local command=$*

	rm -f "$OTHER_BACKGROUND_OUTPUTS_FILE"

	# Collect arg outputs in `OTHER_BACKGROUND_OUTPUTS_FILE` to print at the end
	# Otherwise, arg outputs are interleaved with `&` outputs
	for number in $(seq "$start" "$finish"); do
		echo
		echo_eval "${command//~~/$number}" >> "$OTHER_BACKGROUND_OUTPUTS_FILE" &
	done

	wait

	echo
	cat "$OTHER_BACKGROUND_OUTPUTS_FILE"
}

function other_keymap_c {
	echo -n "$(eval "$(prev_command)" | bw | ruby_strip)" | pbcopy
}

function other_keymap_cc {
	echo -n "$(prev_command)" | pbcopy
}

function other_keymap_d {
	local url=${*:-$(pbpaste)}
	[[ -z $url ]] && return

	# Strip protocol and path
	local domain=${${${url}#*://}%%/*}

	if [[ -z $ZSHRC_UNDER_TESTING ]]; then
		dig +short "$domain" | args_keymap_s
	else
		printf "test output for\n%s" "$domain" | args_keymap_s
	fi
}

function other_keymap_df {
	sudo dscacheutil -flushcache
	sudo killall -HUP mDNSResponder
}

function other_keymap_e {
	local target_path=${*:-.}

	open -na 'IntelliJ IDEA.app' --args "$target_path"
}

function other_keymap_f {
	local start=$1; shift
	local finish=$1; shift # `end` is a reserved keyword
	local command=$*

	for number in $(seq "$start" "$finish"); do
		echo
		echo_eval "${command//~~/$number}"
	done
}

function other_keymap_i {
	local index=$1
	local file=$2

	other_helpers_validate_indexes 'Usage: oi <index> <file>?' "$index" || return
	other_helpers_validate_file "$file" || return

	# `-f` names the column
	# `${file:+...}` adds no arg when there is no file, so `mlr` reads the pipe
	other_helpers_mlr cut -f "$index" ${file:+"$file"}
}

function other_keymap_id {
	local index=$1
	local file=$2

	other_helpers_validate_indexes 'Usage: oid <index> <file>?' "$index" || return
	other_helpers_validate_file "$file" || return

	# `-f` names the column
	# `${file:+...}` adds no arg when there is no file, so `mlr` reads the pipe
	other_helpers_mlr cut --complement -f "$index" ${file:+"$file"}
}

function other_keymap_ii {
	local index=$1
	local file=$2

	other_helpers_validate_indexes 'Usage: oii <index> <file>?' "$index" || return
	other_helpers_validate_file "$file" || return

	# `-t` is natural sort, so `x9` lands before `x10`
	# `${file:+...}` adds no arg when there is no file, so `mlr` reads the pipe
	other_helpers_mlr sort -t "$index" ${file:+"$file"}
}

function other_keymap_ix {
	local column_1=$1
	local column_2=$2
	local file=$3

	other_helpers_validate_indexes 'Usage: oix <i1> <i2> <file>?' "$column_1" "$column_2" || return
	other_helpers_validate_file "$file" || return

	# `$[[[n]]]` is the value of column `n`
	local mlr_script='tmp = $[[[@c1]]]; $[[[@c1]]] = $[[[@c2]]]; $[[[@c2]]] = tmp'

	# `-s` passes the indexes in as `@c1` and `@c2` for `mlr_script` to use
	# `${file:+...}` adds no arg when there is no file, so `mlr` reads the pipe
	other_helpers_mlr put -s c1="$column_1" -s c2="$column_2" "$mlr_script" ${file:+"$file"}
}

function other_keymap_j {
	local url=$1
	local regex=$2
	local num_lines=${3:-0}

	[[ -z $url ]] && return

	curl --silent "$url" | jq | {
		if [[ -z "$regex" ]]; then
			cat
		else
			grep --ignore-case -A"$num_lines" -B"$num_lines" "$regex"
		fi
	}
}

function other_keymap_k {
	# If pasteboard contains terminal output looking text, archive it
	if [[ $(pbpaste | compact | strip | sed -n '$p') == \$* ]]; then
		local filename; filename="$OTHER_TERMINAL_DUMP_DIR/$(gdate +'%Y-%m-%d_%H.%M.%S.%6N').txt"

		mkdir -p "$OTHER_TERMINAL_DUMP_DIR"
		pbpaste > "$filename"

		# Taint the pasteboard, so that it doesn't get dumped again
		printf "%s\n\n(Dumped to '%s')" "$(pbpaste)" "$filename" | pbcopy
	fi

	[[ -z $ZSHRC_UNDER_TESTING ]] && clear && printf '\e[3J'
}

function other_keymap_kc {
	rm -rf "$OTHER_TERMINAL_DUMP_DIR"
}

function other_keymap_kk {
	mkdir -p "$OTHER_TERMINAL_DUMP_DIR"
	cd "$OTHER_TERMINAL_DUMP_DIR" && nav_keymap_n || return
}

function other_keymap_m {
	local target_path=${*:-.}

	mate "$target_path"
}

function other_keymap_n {
	local temp_file; temp_file=$(mktemp)

	# Write ciphertext to a temp file instead of capturing stdout
	# Capturing `$(pbpaste | openssl ...)` breaks the password prompt (`bad password read`)
	if ! pbpaste | openssl enc -aes-256-cbc -pbkdf2 -iter 600000 -salt -a -out "temp_file"; then
		# Delete temp file in case of errors, e.g mismatched passwords
		rm -f "temp_file"
		return 1
	fi

	# Embed the ciphertext in a decrypt one-liner that recipients run as-is.
	# Single quotes can hold multi-line base64, which never contains `'`
	# The leading `echo` prints a blank line before the password prompt
	# The `awk` prints one after it (by waiting for output) and supplies the final newline
	local decrypt_command; decrypt_command="echo; echo '$(< "temp_file")' | openssl enc -aes-256-cbc -pbkdf2 -iter 600000 -salt -a -d | awk 'NR==1{print \"\"}1'"
	rm -f "temp_file"

	echo
	echo "$decrypt_command"
	echo -n "$decrypt_command" | pbcopy
	green_bar 'Copied to pasteboard'
}

function other_keymap_o {
	local target_path=$*

	# If target is empty, open the current directory
	[[ -z $target_path ]] && open . && return

	# If target is a local directory or file, open it
	[[ -d $target_path ]] && open "$target_path" && return
	[[ -f $target_path ]] && open "$target_path" && return

	# If target is a list of urls, open them
	local has_urls
	while IFS= read -r url; do
		[[ -z $url ]] && continue

		has_urls=1
		open "$url"
	done < <(echo "$target_path" | extract_urls | bw)
	[[ -n $has_urls ]] && return

	# If we didn't open anything, return exit code `1`
	return 1
}

function other_keymap_p {
	pbpaste
}

function other_keymap_q {
	local sql

	# When invoked after a pipe `|`
	if [[ ! -t 0 ]]; then
		sql=$(cat)

	# When invoked with a cli arg
	elif [[ -n $* ]]; then
		sql=$*

	# When invoked as standalone command
	else
		sql=$(pbpaste)
	fi

	# shellcheck disable=SC2086 # Empty quotes break Ruby's `gets` method
	ruby ~/GitHub/jasonzhao6/sql_formatter.rb/run.rb $sql
}

function other_keymap_r {
	local before=$1
	local after=$2

	[[ -z $before || -z $after ]] && return

	for file in *"$before"*; do
		mv "$file" "${file//"$before"/$after}"
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

function other_keymap_v {
	if [[ -z $ZSHRC_UNDER_TESTING ]]; then
		pbpaste | other_helpers_speakable | say -r 300
	else
		pbpaste | other_helpers_speakable
	fi
}

function other_keymap_w {
	local seconds=1
	if [[ $1 =~ ^[0-9]+(\.[0-9]+)?$ ]]; then # Match integer or decimal
		seconds=$1; shift
	fi
	local command=$*

	local output
	while true; do
		output=$(eval "$command")

		other_keymap_k

		echo "$(yellow_fg '$') $command"
		echo
		echo "$output"
		echo
		echo -n 'Last executed: '
		date +"%Y-%m-%d %H:%M:%S"

		sleep "$seconds"
	done
}

function other_keymap_x {
	local file_1=${1:-$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1}
	local file_2=${2:-$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2}

	other_helpers_validate_file "$file_1" || return
	other_helpers_validate_file "$file_2" || return

	# Inner join file 1 with file 2's distinct 1st-column values
	# `compact` drops the inner call's leading blank, else it joins as an empty key
	other_helpers_mlr join -j 1 -f <(other_helpers_mlr uniq -g 1 "$file_2" | compact) "$file_1"
}

function other_keymap_xx {
	local file_1=${1:-$OTHER_KEYMAP_DEFAULT_DIFF_FILE_1}
	local file_2=${2:-$OTHER_KEYMAP_DEFAULT_DIFF_FILE_2}

	other_helpers_validate_file "$file_1" || return
	other_helpers_validate_file "$file_2" || return

	# Anti join file 1 with file 2's 1st-column values
	other_helpers_mlr join --np --ur -j 1 -f "$file_2" "$file_1"
}

function other_keymap_y {
	pbcopy
}
