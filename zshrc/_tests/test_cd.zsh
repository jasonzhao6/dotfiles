function test__.. {
	assert "$(
		rm -rf /tmp/_..
		mkdir -p /tmp/_../1
		cd /tmp/_../1 || return
		..
		pwd
		rm -rf /tmp/_..
	)" '/tmp/_..'
}; run_with_filter test__..

function test__... {
	assert "$(
		rm -rf /tmp/_...
		mkdir -p /tmp/_.../1/2
		cd /tmp/_.../1/2 || return
		...
		pwd
		rm -rf /tmp/_...
	)" '/tmp/_...'
}; run_with_filter test__...

function test__.... {
	assert "$(
		rm -rf /tmp/_....
		mkdir -p /tmp/_..../1/2/3
		cd /tmp/_..../1/2/3 || return
		....
		pwd
		rm -rf /tmp/_....
	)" '/tmp/_....'
}; run_with_filter test__....

function test__..... {
	assert "$(
		rm -rf /tmp/_.....
		mkdir -p /tmp/_...../1/2/3/4
		cd /tmp/_...../1/2/3/4 || return
		.....
		pwd
		rm -rf /tmp/_.....
	)" '/tmp/_.....'
}; run_with_filter test__.....

function test__...... {
	assert "$(
		rm -rf /tmp/_......
		mkdir -p /tmp/_....../1/2/3/4/5
		cd /tmp/_....../1/2/3/4/5 || return
		......
		pwd
		rm -rf /tmp/_......
	)" '/tmp/_......'
}; run_with_filter test__......

function test__....... {
	assert "$(
		rm -rf /tmp/_.......
		mkdir -p /tmp/_......./1/2/3/4/5/6
		cd /tmp/_......./1/2/3/4/5/6 || return
		.......
		pwd
		rm -rf /tmp/_.......
	)" '/tmp/_.......'
}; run_with_filter test__.......

function test__........ {
	assert "$(
		rm -rf /tmp/_........
		mkdir -p /tmp/_......../1/2/3/4/5/6/7
		cd /tmp/_......../1/2/3/4/5/6/7 || return
		........
		pwd
		rm -rf /tmp/_........
	)" '/tmp/_........'
}; run_with_filter test__........

function test__......... {
	assert "$(
		rm -rf /tmp/_.........
		mkdir -p /tmp/_........./1/2/3/4/5/6/7/8
		cd /tmp/_........./1/2/3/4/5/6/7/8 || return
		.........
		pwd
		rm -rf /tmp/_.........
	)" '/tmp/_.........'
}; run_with_filter test__.........

function test__.......... {
	assert "$(
		rm -rf /tmp/_..........
		mkdir -p /tmp/_........../1/2/3/4/5/6/7/8/9
		cd /tmp/_........../1/2/3/4/5/6/7/8/9 || return
		..........
		pwd
		rm -rf /tmp/_..........
	)" '/tmp/_..........'
}; run_with_filter test__..........

function test__cd-__with_dir {
	assert "$(cd- ~/Documents 2>&1; pwd)" "$HOME/Documents"
}; run_with_filter test__cd-__with_dir

function test__cd-__with_file {
	assert "$(cd- ~/Documents/.zshrc 2>&1; pwd)" "$HOME/Documents"
}; run_with_filter test__cd-__with_file

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

function test__cde {
	# Skip: Not testing b/c function has other side effects
	return
}

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
