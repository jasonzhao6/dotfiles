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
