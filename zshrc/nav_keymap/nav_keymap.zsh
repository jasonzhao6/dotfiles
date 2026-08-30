NAV_NAMESPACE='nav_keymap'
NAV_ALIAS='n'
NAV_DOT="${NAV_ALIAS}${KEYMAP_DOT}"

NAV_KEYMAP=(
	"${NAV_ALIAS} <directory> # Go to directory"
	"${NAV_ALIAS} <file> # Clear screen, cd to folder & render file"
	''
	"${NAV_DOT}n <match>* <-mismatch>* # List visible files & dirs"
	"${NAV_DOT}nf <match>* <-mismatch>* # List visible files"
	"${NAV_DOT}nd <match>* <-mismatch>* # List visible dirs"
	''
	"${NAV_DOT}a <match>* <-mismatch>* # List hidden files & dirs"
	"${NAV_DOT}af <match>* <-mismatch>* # List hidden files"
	"${NAV_DOT}ad <match>* <-mismatch>* # List hidden dirs"
	''
	"${NAV_DOT}u <levels>? # Go up 1+ directories (Default: 1)"
	"${NAV_DOT}uu # Go up to git repo root"
	''
	"${NAV_DOT}b # Go to Desktop"
	"${NAV_DOT}m # Go to Documents"
	"${NAV_DOT}w # Go to Downloads"
	''
	"${NAV_DOT}d # Go to dotfiles"
	"${NAV_DOT}dd # Go to dotfiles, open GitHub Desktop"
	"${NAV_DOT}s # Go to scratch"
	"${NAV_DOT}ss # Go to scratch, open GitHub Desktop"
	"${NAV_DOT}z # Go to scratch/claude"
	''
	"${NAV_DOT}y <path>? # Copy path to pasteboard (Default: \`pwd\`)"
	"${NAV_DOT}p # Go to dir from pasteboard path"
	''
	"${NAV_DOT}t <match>* <-mismatch>* # Show shortlist, \`cd\` when only one match"
	"${NAV_DOT}tt <dir>? # Add to shortlist, \`cd\` if not CWD"
	"${NAV_DOT}td <dir> # Delete from shortlist"
	"${NAV_DOT}tc # Clear shortlist"
	''
	"${NAV_DOT}h <match>* <-mismatch>* # Show history, \`cd\` when only one match"
	"${NAV_DOT}hc # Clear history"
	''
	"${NAV_DOT}o # Order files and dirs chronologically"
	"${NAV_DOT}of # Order files by size"
	"${NAV_DOT}od <levels>? # Order dirs by size"
	''
	"${NAV_DOT}j # Clear screen & render next file in args"
	"${NAV_DOT}k # Clear screen & render prev file in args"
	"${NAV_DOT}v # Clear screen & render file in pasteboard"
	"${NAV_DOT}r # Clear screen & re-render last file"
	"${NAV_DOT}rr # Same as \`nr\` without scrolling to top"
	''
	"${NAV_DOT}c # (Reserved: Netcat)"
	"${NAV_DOT}l # (Reserved: Number lines)"
)

keymap_init $NAV_NAMESPACE $NAV_ALIAS "${NAV_KEYMAP[@]}"

function nav_keymap {
	local target_path=$1

	# If target is a directory, go into it
	if [[ -d "$target_path" ]]; then
		cd "$target_path" && nav_keymap_n || return
	# If target is a file, print it
	elif [[ -f "$target_path" ]]; then
		# If file is already in args, use current cursor
		local cursor; cursor=$(nav_helpers_find_cursor "$target_path")

		# Otherwise, find file in its parent dir and set cursor
		if [[ -z $cursor ]]; then
			if [[ "$target_path" == */* ]]; then
				cd "${target_path:h}" || return
				target_path=${target_path:t}
			fi

			# List siblings (hidden vs visible), so the cursor can be set
			if [[ "$target_path" == .* ]]; then
				nav_keymap_a > /dev/null
			else
				nav_keymap_n > /dev/null
			fi

			cursor=$(nav_helpers_find_cursor "$target_path")
		fi

		NAV_CURSOR=$cursor
		nav_helpers_render_cursor_as_file
	else
		keymap_show $NAV_NAMESPACE $NAV_ALIAS ${#NAV_KEYMAP} "${NAV_KEYMAP[@]}" "$@"
	fi
}

#
# Key mappings (Alphabetized)
#

# Sources
source "$ZSHRC_SRC_DIR/$NAV_NAMESPACE/nav_helpers.zsh"

# Constants
NAV_HISTORY_FILE="$ZSHRC_DATA_DIR/nav.history.txt"
NAV_HISTORY_MAX=1000
NAV_MDCAT_CONFIG_HOME="$ZSHRC_SRC_DIR/$NAV_NAMESPACE" # Holds `mdcat/config.toml`
NAV_SHORTLIST_FILE="$ZSHRC_DATA_DIR/nav.shortlist.txt"

# States
NAV_CURSOR=0

# shellcheck disable=SC2120 # `filters` is an optional arg
function nav_keymap_a {
	local filters=("$@")

	setopt NULL_GLOB
	ls -d .* | args_keymap_s "${filters[@]}"
	unsetopt NULL_GLOB
}

function nav_keymap_ad {
	local filters=("$@")

	ls -d .*/ | args_keymap_s "${filters[@]}"
}

function nav_keymap_af {
	local filters=("$@")

	# shellcheck disable=SC2010
	ls -pd .* | grep -v '/' | args_keymap_s "${filters[@]}"
}

function nav_keymap_b {
	cd ~/Desktop && nav_keymap_n || true
}

function nav_keymap_d {
	cd ~/GitHub/jasonzhao6/dotfiles && nav_keymap_n || true
}

function nav_keymap_dd {
	nav_keymap_d && github_keymap_a
}

function nav_keymap_h {
	local filters=("$@")

	if [[ ! -f "$NAV_HISTORY_FILE" || ! -s "$NAV_HISTORY_FILE" ]]; then
		red_bar 'Navigation history is empty'
		return
	fi

	args_keymap_s "${filters[@]}" < "$NAV_HISTORY_FILE"

	nav_helpers_cd_if_only_match
}

function nav_keymap_hc {
	if [[ ! -f "$NAV_HISTORY_FILE" ]]; then
		red_bar 'Navigation history is empty'
		return
	fi

	local count; count=$(wc -l < "$NAV_HISTORY_FILE" | tr -d ' ')
	rm -f "$NAV_HISTORY_FILE"
	green_bar "Cleared $count history entries"
}

function nav_keymap_j {
	nav_helpers_populate_args_when_empty

	local size; size=$(args_helpers_size)

	if [[ $NAV_CURSOR -ge $size ]]; then
		red_bar 'Reached the end of file list'
		return
	fi

	NAV_CURSOR=$((NAV_CURSOR + 1))
	nav_helpers_render_cursor_as_file
}

function nav_keymap_k {
	nav_helpers_populate_args_when_empty

	local size; size=$(args_helpers_size)

	if [[ $size -eq 0 || $NAV_CURSOR -eq 1 ]]; then
		red_bar 'Reached the beginning of file list'
		return
	fi

	if [[ $NAV_CURSOR -eq 0 ]]; then
		NAV_CURSOR=$size
	else
		NAV_CURSOR=$((NAV_CURSOR - 1))
	fi

	nav_helpers_render_cursor_as_file
}

function nav_keymap_m {
	cd ~/Documents && nav_keymap_n || true
}

# shellcheck disable=SC2120 # `filters` is an optional arg
function nav_keymap_n {
	local filters=("$@")

	NAV_CURSOR=0
	nav_helpers_history_add "$(pwd)"

	ls | args_keymap_s "${filters[@]}"
}

function nav_keymap_nd {
	local filters=("$@")

	ls -d -- */ | args_keymap_s "${filters[@]}"
}

function nav_keymap_nf {
	local filters=("$@")

	# shellcheck disable=SC2010
	ls -p | grep -v '/' | args_keymap_s "${filters[@]}"
}

function nav_keymap_o {
	# `-A` lists dotfiles while omitting `.` and `..`
	ls -lhtrA | tail -n +2
}

function nav_keymap_od {
	local levels="${1:-1}"

	du -hd "$levels" | sort -h
}

function nav_keymap_of {
	# `-A` lists dotfiles while omitting `.` and `..`; `grep` drops the dirs
	ls -lhSrA | tail -n +2 | grep -v '^d'
}

function nav_keymap_p {
	local target_path; target_path=$(nav_helpers_copied_path)

	if [[ ! -f $target_path && ! -d $target_path ]]; then
		red_bar 'Invalid path in pasteboard'
		return
	fi

	# For a file path, go to its parent folder
	if [[ -f $target_path ]]; then
		cd "${target_path:h}" && nav_keymap_n || return
	else
		cd "$target_path" && nav_keymap_n || return
	fi
}

function nav_keymap_r {
	local scroll_to_top=${1:-true}

	nav_helpers_populate_args_when_empty

	local size; size=$(args_helpers_size)

	if [[ $size -eq 0 ]]; then
		red_bar 'No current file in the list'
		return
	fi

	if [[ $NAV_CURSOR -eq 0 ]]; then
		NAV_CURSOR=1
	fi

	nav_helpers_render_cursor_as_file "$scroll_to_top"
}

function nav_keymap_rr {
	nav_keymap_r false
}

function nav_keymap_s {
	cd ~/GitHub/jasonzhao6/scratch && nav_keymap_n || true
}

function nav_keymap_ss {
	nav_keymap_s && github_keymap_a
}

# shellcheck disable=SC2120 # `filters` is an optional arg
function nav_keymap_t {
	local filters=("$@")

	nav_helpers_shortlist_prune

	if [[ ! -f "$NAV_SHORTLIST_FILE" || ! -s "$NAV_SHORTLIST_FILE" ]]; then
		red_bar 'Path shortlist is empty'
		return
	fi

	args_keymap_s "${filters[@]}" < "$NAV_SHORTLIST_FILE"

	nav_helpers_cd_if_only_match
}

function nav_keymap_tc {
	rm -f "$NAV_SHORTLIST_FILE"
}

function nav_keymap_td {
	local target_dir=$1

	if [[ -z $target_dir ]]; then
		red_bar 'Usage: ntd <dir>'
		return
	fi

	if [[ ! -f "$NAV_SHORTLIST_FILE" || ! -s "$NAV_SHORTLIST_FILE" ]]; then
		red_bar 'Path shortlist is empty'
		return
	fi

	local remaining; remaining=$(grep -Fxv "$target_dir" "$NAV_SHORTLIST_FILE" || true)
	local original; original=$(cat "$NAV_SHORTLIST_FILE")

	if [[ "$remaining" == "$original" ]]; then
		red_bar "Path not found in shortlist"
		return
	fi

	printf '%s\n' "$remaining" > "$NAV_SHORTLIST_FILE"

	nav_keymap_t
}

function nav_keymap_tt {
	local target_dir=${1:-$(pwd)}

	# Resolve to an absolute path, which also validates the dir
	local full_path
	full_path=$(cd "$target_dir" 2>/dev/null && pwd) || {
		red_bar "Invalid dir: $target_dir"
		return
	}

	# Add to shortlist (sorted) if not already present
	if [[ ! -f "$NAV_SHORTLIST_FILE" ]]; then
		echo "$full_path" > "$NAV_SHORTLIST_FILE"
	elif ! grep -qFx "$full_path" "$NAV_SHORTLIST_FILE"; then
		echo "$full_path" >> "$NAV_SHORTLIST_FILE"
		sort -o "$NAV_SHORTLIST_FILE" "$NAV_SHORTLIST_FILE"
	fi

	# Follow the dir just added, unless already there
	[[ $full_path == "$(pwd)" ]] && return
	cd "$full_path" && nav_keymap_n || true
}

function nav_keymap_u {
	local levels=${1:-1}
	local target_path=''

	if [[ ! $levels =~ ^[1-9][0-9]*$ ]]; then
		red_bar 'Usage: nu <levels>'
		return
	fi

	local i
	for ((i = 0; i < levels; i++)); do
		target_path+='../'
	done

	cd "$target_path" || return
	nav_keymap_n
}

function nav_keymap_uu {
	local repo_root; repo_root=$(git rev-parse --show-toplevel 2> /dev/null)

	if [[ -z $repo_root ]]; then
		red_bar 'Not in a git repo'
		return
	fi

	cd "$repo_root" || return
	nav_keymap_n
}

function nav_keymap_v {
	local target_path; target_path=$(nav_helpers_copied_path)

	if [[ ! -f $target_path ]]; then
		red_bar 'Invalid file path in pasteboard' && return
	fi

	nav_keymap "$target_path"
}

function nav_keymap_w {
	cd ~/Downloads && nav_keymap_n || true
}

function nav_keymap_y {
	local file="$1"

	if [[ -n $file ]]; then
		echo -n "$(pwd)/$file" | pbcopy
	else
		pwd | tr -d '\n' | pbcopy
	fi
}

function nav_keymap_z {
	cd ~/GitHub/jasonzhao6/scratch/claude && nav_keymap_n || true
}
