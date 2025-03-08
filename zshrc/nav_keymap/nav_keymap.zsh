NAV_NAMESPACE='nav_keymap'
NAV_ALIAS='n'
NAV_DOT="${NAV_ALIAS}${KEYMAP_DOT}"

NAV_KEYMAP=(
	"${NAV_ALIAS} {directory} # Go to directory"
	"${NAV_DOT}t # Go to directory in pasteboard"
	"${NAV_DOT}h # Go to github"
	"${NAV_DOT}s # Go to scratch"
	"${NAV_DOT}d # Go to dotfiles"
	"${NAV_DOT}m # Go to Documents"
	"${NAV_DOT}w # Go to Downloads"
	"${NAV_DOT}v # Go to Desktop"
	''
	"${NAV_DOT}n {match}* {-mismatch}* # List visible directories & files"
	"${NAV_DOT}a {match}* {-mismatch}* # List hidden directories & files"
	"${NAV_DOT}o {match}* {-mismatch}* # List visible directories"
	"${NAV_DOT}oo {match}* {-mismatch}* # List hidden directories"
	"${NAV_DOT}e {match}* {-mismatch}* # List visible files"
	"${NAV_DOT}ee {match}* {-mismatch}* # List hidden files"
	''
	"${NAV_DOT}u # Go up one directory"
	"${NAV_DOT}uu # Go up two directories"
	"${NAV_DOT}uuu # Go up three directories"
)

keymap_init $NAV_NAMESPACE $NAV_ALIAS "${NAV_KEYMAP[@]}"

function nav_keymap {
	# If the first arg is a directory, go to it
	local directory="$1"
	if [[ -d "$directory" ]]; then
		cd "$directory" && nav_keymap_n || return
		return
	fi

	keymap_show $NAV_NAMESPACE $NAV_ALIAS ${#NAV_KEYMAP} "${NAV_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function nav_keymap_a {
	local filters=("$@")

	ls -d .* | args_keymap_s "${filters[@]}"
}

function nav_keymap_d {
	cd ~/github/jasonzhao6/dotfiles && nav_keymap_n || true
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

function nav_keymap_h {
	cd ~/github && nav_keymap_n || true
}

function nav_keymap_m {
	cd ~/Documents && nav_keymap_n || true
}

# shellcheck disable=SC2120 # `filters` is an optional arg
function nav_keymap_n {
	local filters=("$@")

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

function nav_keymap_s {
	cd ~/github/jasonzhao6/scratch && nav_keymap_n || true
}

function nav_keymap_t {
	# Note: Do not use `local path`- It will overwrite $PATH in subshell
	local target_path; target_path=$(paste_when_empty "$@")

	# If it's not a folder path, go to its parent folder
	if [[ ! -d $target_path ]]; then
		target_path=${${target_path}%/*}
	fi

	# Go to folder
	cd $target_path && nav_keymap_n || true
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
	cd ~/Desktop && nav_keymap_n || true
}

function nav_keymap_w {
	cd ~/Downloads && nav_keymap_n || true
}
