NAV_NAMESPACE='nav_keymap'
NAV_ALIAS='n'
NAV_DOT="${NAV_ALIAS}${KEYMAP_DOT}"

NAV_KEYMAP=(
	"${NAV_ALIAS} <directory> # Go to directory"
	"${NAV_ALIAS} <file> # Clear screen & render file"
	''
	"${NAV_DOT}n <match>* <-mismatch>* # List visible directories & files"
	"${NAV_DOT}a <match>* <-mismatch>* # List hidden directories & files"
	"${NAV_DOT}o <match>* <-mismatch>* # List visible directories"
	"${NAV_DOT}oo <match>* <-mismatch>* # List hidden directories"
	"${NAV_DOT}e <match>* <-mismatch>* # List visible files"
	"${NAV_DOT}ee <match>* <-mismatch>* # List hidden files"
	''
	"${NAV_DOT}u # Go up one directory"
	"${NAV_DOT}uu # Go up two directories"
	"${NAV_DOT}uuu # Go up three directories"
	''
	"${NAV_DOT}t # Go to directory in pasteboard"
	"${NAV_DOT}tt <file>? # Copy current path to pasteboard"
	"${NAV_DOT}y # Yank current path to MRU queue"
	"${NAV_DOT}p # Put latest path from MRU queue"
	"${NAV_DOT}q <match>* <-mismatch>* # List MRU queue, \`cd\` when only one match"
	"${NAV_DOT}qk <count> # Keep top N entries of MRU queue"
	"${NAV_DOT}qq # Clear MRU queue"
	''
	"${NAV_DOT}h <match>* <-mismatch>* # Go to GitHub"
	"${NAV_DOT}i # Go to Excalidraw"
	"${NAV_DOT}b # Go to Desktop"
	"${NAV_DOT}m # Go to Documents"
	"${NAV_DOT}w # Go to Downloads"
	''
	"${NAV_DOT}d # Go to dotfiles"
	"${NAV_DOT}dd # Go to dotfiles, open GitHub Desktop"
	"${NAV_DOT}s # Go to scratch"
	"${NAV_DOT}ss # Go to scratch, open GitHub Desktop"
	"${NAV_DOT}z # Go to scratch/claude"
	"${NAV_DOT}zz # Render latest claude plan"
	''
	"${NAV_DOT}g <levels>? # Sort subfolders by size"
	"${NAV_DOT}f # Sort files by size"
	"${NAV_DOT}r # Sort files by recent"
	''
	"${NAV_DOT}j # Clear screen & render next file in args"
	"${NAV_DOT}k # Clear screen & render prev file in args"
	"${NAV_DOT}x # Clear screen & rerender current file"
	"${NAV_DOT}v # Clear screen & render file in pasteboard"
	''
	"${NAV_DOT}c # (Reserved: Netcat)"
	"${NAV_DOT}l # (Reserved: Number lines)"
)

keymap_init $NAV_NAMESPACE $NAV_ALIAS "${NAV_KEYMAP[@]}"

function nav_keymap {
	local target=$1

	# If the target is a directory, go to it
	if [[ -d "$target" ]]; then
		cd "$target" && nav_keymap_n || return
		return
	fi

	# If the target is a file, set cursor and print it
	if [[ -f "$target" ]]; then
		local cursor
		cursor=$(args_helpers_plain | sed 's/ *#.*//' | strip | grep -nFx "$target" | head -1 | cut -d: -f1)
		if [[ -n $cursor ]]; then
			NAV_CURSOR=$cursor
			nav_helpers_render_cursor_as_file
		else
			nav_helpers_render_file "$target"
		fi
		return
	fi

	keymap_show $NAV_NAMESPACE $NAV_ALIAS ${#NAV_KEYMAP} "${NAV_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

# Sources
source "$ZSHRC_SRC_DIR/$NAV_NAMESPACE/nav_helpers.zsh"

# Constants
NAV_CLAUDE_DIR="$HOME/GitHub/jasonzhao6/scratch/claude"
NAV_CLAUDE_PLANS_DIR="$NAV_CLAUDE_DIR/plans"
NAV_MD_FILE_EXTENSION='*.md'
NAV_MRU_FILE="$ZSHRC_DATA_DIR/nav.mru.txt"

# States
NAV_CURSOR=0
NAV_V_LAST_FILE=

function nav_keymap_a {
	local filters=("$@")

	setopt NULL_GLOB
	ls -d .* | args_keymap_s "${filters[@]}"
	unsetopt NULL_GLOB
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

function nav_keymap_e {
	local filters=("$@")

	# shellcheck disable=SC2010
	ls -p | grep -v '/' | args_keymap_s "${filters[@]}"
}

function nav_keymap_ee {
	local filters=("$@")

	# shellcheck disable=SC2010
	ls -pd .* | grep -v '/' | args_keymap_s "${filters[@]}"
}

function nav_keymap_f {
	ls -lhSr | tail -n +2
}

function nav_keymap_g {
	local levels="${1:-1}"

	du -hd "$levels" | sort -h
}

function nav_keymap_h {
	local filters=("$@")

	cd ~/GitHub && nav_keymap_n "${filters[@]}" || true
}

function nav_keymap_i {
	cd ~/GitHub/jasonzhao6/excalidraw && nav_keymap_n || true
}

function nav_keymap_j {
	local size; size=$(args_helpers_size)

	if [[ $NAV_CURSOR -ge $size ]]; then
		red_bar 'Reached the end of file list'
		return
	fi

	NAV_CURSOR=$((NAV_CURSOR + 1))
	nav_helpers_render_cursor_as_file
}

function nav_keymap_k {
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
	echo
	ls | args_keymap_s "${filters[@]}"
}

function nav_keymap_o {
	local filters=("$@")

	ls -d -- */ | args_keymap_s "${filters[@]}"
}

function nav_keymap_oo {
	local filters=("$@")

	ls -d .*/ | args_keymap_s "${filters[@]}"
}

function nav_keymap_p {
	local head; head=$(head -1 "$NAV_MRU_FILE" 2>/dev/null)
	if [[ -z "$head" ]]; then
		red_bar 'MRU queue is empty'
		return
	fi
	cd "$head" && nav_keymap_n || true
}

function nav_keymap_q {
	local filters=("$@")

	# Drop entries whose directory no longer exists
	nav_helpers_mru_prune

	if [[ ! -f "$NAV_MRU_FILE" || ! -s "$NAV_MRU_FILE" ]]; then
		red_bar 'MRU queue is empty'
		return
	fi

	# Narrow to matching entries; with no filters, every entry matches
	local matched
	if [[ -n "${filters[*]}" ]]; then
		matched=$(cat "$NAV_MRU_FILE" | args_helpers_filter "${filters[@]}" 2>/dev/null)
	else
		matched=$(cat "$NAV_MRU_FILE")
	fi

	# `cd` when exactly one entry matches
	if [[ -n "$matched" ]]; then
		local count; count=$(echo "$matched" | wc -l | tr -d ' ')
		if [[ $count -eq 1 ]]; then
			local match_path; match_path=$(echo "$matched" | bw | strip)
			nav_helpers_mru_add "$match_path"
			cd "$match_path" && nav_keymap_n || true
			return
		fi
	fi

	cat "$NAV_MRU_FILE" | args_keymap_s "${filters[@]}"
}

function nav_keymap_qk {
	local count=$1

	if [[ ! $count =~ ^[1-9][0-9]*$ ]]; then
		red_bar 'Usage: nqk <count>'
		return
	fi

	if [[ ! -f "$NAV_MRU_FILE" || ! -s "$NAV_MRU_FILE" ]]; then
		red_bar 'MRU queue is empty'
		return
	fi

	local kept; kept=$(head -n "$count" "$NAV_MRU_FILE")
	printf '%s\n' "$kept" > "$NAV_MRU_FILE"
	nav_keymap_q
}

function nav_keymap_qq {
	rm -f "$NAV_MRU_FILE"
}

function nav_keymap_r {
	ls -lhtr | tail -n +2
}

function nav_keymap_s {
	cd ~/GitHub/jasonzhao6/scratch && nav_keymap_n || true
}

function nav_keymap_ss {
	nav_keymap_s && github_keymap_a
}

function nav_keymap_t {
	# Note: Do not use `local path`- It will overwrite $PATH in subshell
	local target_path; target_path=$(pbpaste)

	# Expand leading `~` to $HOME
	target_path=${target_path/#\~/$HOME}

	# Strip trailing space-separated tokens (branch, AWS account, region, etc.)
	# until what remains is a valid file or folder. Stops when no more spaces
	# are left to trim, which correctly handles paths with embedded spaces.
	local prev=''
	while [[ -n $target_path && ! -f $target_path && ! -d $target_path && $target_path != $prev ]]; do
		prev=$target_path
		target_path=${target_path% *}
	done

	# If nothing remained valid, error
	if [[ ! -f $target_path && ! -d $target_path ]]; then
		red_bar 'Invalid path in pasteboard'
		return
	fi

	# If it's a file path, go to its parent folder
	if [[ -f $target_path ]]; then
		target_path=${${target_path}%/*}
	fi

	# Go to folder
	cd $target_path && nav_keymap_n || true
}

function nav_keymap_tt {
	local file="$1"

	if [[ -n $file ]]; then
		echo -n "$(pwd)/$file" | pbcopy
	else
		pwd | tr -d '\n' | pbcopy
	fi
}

function nav_keymap_u {
	cd ..
	nav_keymap_n
}

function nav_keymap_uu {
	cd ../..
	nav_keymap_n
}

function nav_keymap_uuu {
	cd ../../..
	nav_keymap_n
}

function nav_keymap_v {
	local file; file=$(nav_helpers_copied_file_path)

	# Fall back to the last rendered file (allows re-rendering after edits)
	if [[ ! -f $file ]]; then
		if [[ -n $NAV_V_LAST_FILE && -f $NAV_V_LAST_FILE ]]; then
			file=$NAV_V_LAST_FILE
		else
			red_bar 'Invalid file path in pasteboard' && return
		fi
	fi

	NAV_V_LAST_FILE=$file

	nav_helpers_render_file "$file"
}

function nav_keymap_w {
	cd ~/Downloads && nav_keymap_n || true
}

function nav_keymap_x {
	local size; size=$(args_helpers_size)

	if [[ $size -eq 0 ]]; then
		red_bar 'No current file in the list'
		return
	fi

	if [[ $NAV_CURSOR -eq 0 ]]; then
		NAV_CURSOR=1
	fi

	nav_helpers_render_cursor_as_file
}

function nav_keymap_y {
	nav_helpers_mru_add "$(pwd)"
}

function nav_keymap_z {
	cd "$NAV_CLAUDE_DIR" && nav_keymap_n || true
}

function nav_keymap_zz {
	local latest
	latest=$(ls -t "$NAV_CLAUDE_PLANS_DIR"/*.md 2>/dev/null | head -1)

	if [ -n "$latest" ]; then
		cd "$NAV_CLAUDE_PLANS_DIR" && nav_helpers_render_file "$latest"
	else
		red_bar "No plans"
	fi
}
