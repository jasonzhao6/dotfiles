# go up folders
function .. { cd ..; }
function ... { cd ../..; }
function .... { cd ../../..; }
function ..... { cd ../../../..; }
function ...... { cd ../../../../..; }
function ....... { cd ../../../../../..; }
function ........ { cd ../../../../../../..; }
function ......... { cd ../../../../../../../..; }
function .......... { cd ../../../../../../../../..; }

# go to a folder
function cd- {
	CD=$(paste_when_empty "$@")

	if [[ -d $CD ]]; then
		cd "$CD" || return
	else
		cd ${${CD}%/*} || return
	fi
}

# go to mac folders
function cdl { cd ~/Downloads || true; }
function cdm { cd ~/Documents || true; }
function cdt { cd ~/Desktop || true; }
function tmp { cd /tmp || true; }

# go to github folders
# TODO reorg as ~/github/<org>/<repo>
function cdd { cd ~/gh/dotfiles || return; }
function cde {
	cd ~/gh/excalidraw || RETURN
	ruby _touch.rb
	oo
}
function cdg { cd ~/gh || true; }
function cdj { cd ~/gh/jasonzhao6 || true; }
function cds { cd ~/gh/scratch || true; }
function cdtf { cd ~/gh/scratch/tf-debug || true; }