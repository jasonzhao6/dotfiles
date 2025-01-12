NAV_NAMESPACE='nav_keymap'
NAV_ALIAS='n'

NAV_KEYMAP=(
	"$NAV_ALIAS <directory> # Go to directory"
	''
	"$NAV_ALIAS·n <matches>* -<mismatches>* # List files & directories"
	"$NAV_ALIAS·a <matches>* -<mismatches>* # List hidden files & directories"
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

#@jasonzhao6/dotfiles #args_keymap
#$ ls -ld */
#drwxr-xr-x   6 yzhao  staff  192 Jan  5 16:32 vimium/
#drwxr-xr-x  31 yzhao  staff  992 Jan 11 21:45 zshrc/
#
#@jasonzhao6/dotfiles #args_keymap
#$ ls -ld .*/
#drwxr-xr-x  18 yzhao  staff  576 Jan 11 21:45 .git/
#drwxr-xr-x@  8 yzhao  staff  256 Jan 11 21:36 .idea/

#
# Key mappings (Alphabetized)
#

function nav_keymap_a {
	local filters=("$@")

	ls -ld .* | awk '{print $9}' | args_keymap_s "${filters[@]}"
}

# shellcheck disable=SC2120
function nav_keymap_n {
	local filters=("$@")

	ls -l | awk '{print $9}' | args_keymap_s "${filters[@]}"
}
