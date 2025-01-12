NAV_NAMESPACE='nav_keymap'
NAV_ALIAS='n'

NAV_KEYMAP=(
	"$NAV_ALIAS <directory> # Go to directory"
	"$NAV_ALIAS·v # Go to directory of path in pasteboard"
	''
	"$NAV_ALIAS·n <matches>* -<mismatches>* # List directories & files"
	"$NAV_ALIAS·d <matches>* -<mismatches>* # List directories"
	"$NAV_ALIAS·f <matches>* -<mismatches>* # List files"
	"$NAV_ALIAS·a <matches>* -<mismatches>* # List hidden directories & files"
	"$NAV_ALIAS·ad <matches>* -<mismatches>* # List hidden directories"
	"$NAV_ALIAS·af <matches>* -<mismatches>* # List hidden files"
	''
	"$NAV_ALIAS·u # Go up one directory"
	"$NAV_ALIAS·uu # Go up two directories"
	"$NAV_ALIAS·uuu # Go up three directories"
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

	ls -ld .* | awk '{print $9}' | args_keymap_s "${filters[@]}"
}

# TODO add test
function nav_keymap_ad {
	local filters=("$@")

	ls -ld .*/ | awk '{print $9}' | args_keymap_s "${filters[@]}"
}

# TODO add test
function nav_keymap_af {
	local filters=("$@")

	# shellcheck disable=SC2010
	ls -lpd .* | grep -v '/' | awk '{print $9}' | args_keymap_s "${filters[@]}"
}

# TODO add test
function nav_keymap_d {
	local filters=("$@")

	ls -ld -- */ | awk '{print $9}' | args_keymap_s "${filters[@]}"
}

# TODO add test
function nav_keymap_f {
	local filters=("$@")

	# shellcheck disable=SC2010
	ls -lp | grep -v '/' | awk '{print $9}' | args_keymap_s "${filters[@]}"
}

# shellcheck disable=SC2120
function nav_keymap_n {
	local filters=("$@")

	ls -l | awk '{print $9}' | args_keymap_s "${filters[@]}"
}

function nav_keymap_u {
	cd ..
}

function nav_keymap_uu {
	cd ../..
}

function nav_keymap_uuu {
	cd ../../..
}

function nav_keymap_v {
	# Note: Do not use `local path`- It will overwrite $PATH in subshell
	local target_path; target_path=$(paste_when_empty "$@")

	# If it's a folder path, go to that folder
	if [[ -d $target_path ]]; then
		cd "$target_path" || return

	# If it's a file path, go to its parent folder
	else
		cd ${${target_path}%/*} || return
	fi
}
