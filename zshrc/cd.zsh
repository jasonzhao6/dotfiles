# Go up folders
function .. { cd ..; }
function ... { cd ../..; }
function .... { cd ../../..; }
function ..... { cd ../../../..; }
function ...... { cd ../../../../..; }
function ....... { cd ../../../../../..; }
function ........ { cd ../../../../../../..; }
function ......... { cd ../../../../../../../..; }
function .......... { cd ../../../../../../../../..; }

# If it's a file path in pasteboard, go to its parent folder
# If it's a folder path in pasteboard, go to that folder
function cd- {
	# Note: Do not use `local path`- It will overwrite $PATH in subshell
	local target_path; target_path=$(paste_when_empty "$@")

	if [[ -d $target_path ]]; then
		cd "$target_path" || return
	else
		cd ${${target_path}%/*} || return
	fi
}

# Shortcuts to mac folders
function cdl { cd ~/Downloads || true; }
function cdm { cd ~/Documents || true; }
function cdt { cd ~/Desktop || true; }
function tmp { cd /tmp || true; }

# Shortcuts to github folders (~/github/<org>/<repo>)
function cdd { cd "$DOTFILES_DIR" || return; }
function cde { cd ~/gh/excalidraw || return; ruby _touch.rb; oo; }
function cdg { cd ~/gh || true; }
function cdj { cd ~/gh/jasonzhao6 || true; }
function cds { cd ~/gh/scratch || true; }
function cdtf { cd ~/gh/scratch/tf-debug || true; }
