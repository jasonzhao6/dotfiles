NAV_NAMESPACE='nav_keymap'
NAV_ALIAS='n'

NAV_KEYMAP=(
	"$NAV_ALIAS <directory> # Go to directory"
	"$NAV_ALIAS${KEYMAP_DOT}o # Go to directory in pasteboard"
	"$NAV_ALIAS${KEYMAP_DOT}h # Go to github"
	"$NAV_ALIAS${KEYMAP_DOT}s # Go to scratch"
	"$NAV_ALIAS${KEYMAP_DOT}dd # Go to dotfiles"
	"$NAV_ALIAS${KEYMAP_DOT}dl # Go to Downloads"
	"$NAV_ALIAS${KEYMAP_DOT}dm # Go to Documents"
	"$NAV_ALIAS${KEYMAP_DOT}dt # Go to Desktop"
	''
	"$NAV_ALIAS${KEYMAP_DOT}n <match>* <-mismatch>* # List directories & files"
	"$NAV_ALIAS${KEYMAP_DOT}d <match>* <-mismatch>* # List directories"
	"$NAV_ALIAS${KEYMAP_DOT}f <match>* <-mismatch>* # List files"
	"$NAV_ALIAS${KEYMAP_DOT}a <match>* <-mismatch>* # List hidden directories & files"
	"$NAV_ALIAS${KEYMAP_DOT}ad <match>* <-mismatch>* # List hidden directories"
	"$NAV_ALIAS${KEYMAP_DOT}af <match>* <-mismatch>* # List hidden files"
	''
	"$NAV_ALIAS${KEYMAP_DOT}u # Go up one directory"
	"$NAV_ALIAS${KEYMAP_DOT}uu # Go up two directories"
	"$NAV_ALIAS${KEYMAP_DOT}uuu # Go up three directories"
)

keymap_init $NAV_NAMESPACE $NAV_ALIAS "${NAV_KEYMAP[@]}"

function nav_keymap {
	directory="$1"

	# TODO add test
	if [[ -d "$directory" ]]; then
		cd "$directory" || return
		nav_keymap_n
		return
	fi

	keymap_invoke $NAV_NAMESPACE $NAV_ALIAS ${#NAV_KEYMAP} "${NAV_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function nav_keymap_a {
	local filters=("$@")

	ls -d .* | args_keymap_s "${filters[@]}"
}

# TODO add test
function nav_keymap_ad {
	local filters=("$@")

	ls -d .*/ | args_keymap_s "${filters[@]}"
}

# TODO add test
function nav_keymap_af {
	local filters=("$@")

	# shellcheck disable=SC2010
	ls -pd .* | grep -v '/' | args_keymap_s "${filters[@]}"
}

# TODO add test
function nav_keymap_d {
	local filters=("$@")

	ls -d -- */ | args_keymap_s "${filters[@]}"
}

function nav_keymap_dd {
	cd ~/gh/jasonzhao6/dotfiles || true
	nav_keymap_n
}

function nav_keymap_dl {
	cd ~/Downloads || true
	nav_keymap_n
}

function nav_keymap_dm {
	cd ~/Documents || true
	nav_keymap_n
}

function nav_keymap_dt {
	cd ~/Desktop || true
	nav_keymap_n
}

# TODO add test
function nav_keymap_f {
	local filters=("$@")

	# shellcheck disable=SC2010
	ls -p | grep -v '/' | args_keymap_s "${filters[@]}"
}

function nav_keymap_h {
	cd ~/gh || true
	nav_keymap_n
}

# shellcheck disable=SC2120
function nav_keymap_n {
	local filters=("$@")

	ls | args_keymap_s "${filters[@]}"
}

function nav_keymap_o {
	# Note: Do not use `local path`- It will overwrite $PATH in subshell
	local target_path; target_path=$(paste_when_empty "$@")

	# If it's a folder path, go to that folder
	if [[ -d $target_path ]]; then
		cd "$target_path" || return

	# If it's a file path, go to its parent folder
	else
		cd ${${target_path}%/*} || return
	fi

	nav_keymap_n
}

function nav_keymap_s {
	cd ~/gh/scratch || true
	nav_keymap_n
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
