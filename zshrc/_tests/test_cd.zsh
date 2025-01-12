function test__cdl {
	assert "$(cdl; pwd)" "$HOME/Downloads"
}; run_with_filter test__cdl

function test__cdm {
	assert "$(cdm; pwd)" "$HOME/Documents"
}; run_with_filter test__cdm

function test__cdt {
	assert "$(cdt; pwd)" "$HOME/Desktop"
}; run_with_filter test__cdt

function test__tmp {
	assert "$(tmp; pwd)" '/tmp'
}; run_with_filter test__tmp

function test__cdd {
	assert "$(cdd; pwd)" "$DOTFILES_DIR"
}; run_with_filter test__cdd

# Skip: Not testing b/c function has other side effects
# function test__cde

function test__cdg {
	assert "$(cdg; pwd)" "$HOME/gh"
}; run_with_filter test__cdg

function test__cdj {
	assert "$(cdj; pwd)" "$HOME/gh/jasonzhao6"
}; run_with_filter test__cdj

function test__cds {
	assert "$(cds; pwd)" "$HOME/gh/scratch"
}; run_with_filter test__cds

function test__cdtf {
	assert "$(cdtf; pwd)" "$HOME/gh/scratch/tf-debug"
}; run_with_filter test__cdtf
