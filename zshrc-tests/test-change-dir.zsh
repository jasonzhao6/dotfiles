function test--.. {
	assert "$(
		rm -rf /tmp/_..
		mkdir -p /tmp/_../1
		cd /tmp/_../1
		..
		pwd
		rm -rf /tmp/_..
	)" '/tmp/_..'
}; run-with-filter test--..

function test--... {
	assert "$(
		rm -rf /tmp/_...
		mkdir -p /tmp/_.../1/2
		cd /tmp/_.../1/2
		...
		pwd
		rm -rf /tmp/_...
	)" '/tmp/_...'
}; run-with-filter test--...

function test--.... {
	assert "$(
		rm -rf /tmp/_....
		mkdir -p /tmp/_..../1/2/3
		cd /tmp/_..../1/2/3
		....
		pwd
		rm -rf /tmp/_....
	)" '/tmp/_....'
}; run-with-filter test--....

function test--..... {
	assert "$(
		rm -rf /tmp/_.....
		mkdir -p /tmp/_...../1/2/3/4
		cd /tmp/_...../1/2/3/4
		.....
		pwd
		rm -rf /tmp/_.....
	)" '/tmp/_.....'
}; run-with-filter test--.....

function test--...... {
	assert "$(
		rm -rf /tmp/_......
		mkdir -p /tmp/_....../1/2/3/4/5
		cd /tmp/_....../1/2/3/4/5
		......
		pwd
		rm -rf /tmp/_......
	)" '/tmp/_......'
}; run-with-filter test--......

function test--....... {
	assert "$(
		rm -rf /tmp/_.......
		mkdir -p /tmp/_......./1/2/3/4/5/6
		cd /tmp/_......./1/2/3/4/5/6
		.......
		pwd
		rm -rf /tmp/_.......
	)" '/tmp/_.......'
}; run-with-filter test--.......

function test--........ {
	assert "$(
		rm -rf /tmp/_........
		mkdir -p /tmp/_......../1/2/3/4/5/6/7
		cd /tmp/_......../1/2/3/4/5/6/7
		........
		pwd
		rm -rf /tmp/_........
	)" '/tmp/_........'
}; run-with-filter test--........

function test--......... {
	assert "$(
		rm -rf /tmp/_.........
		mkdir -p /tmp/_........./1/2/3/4/5/6/7/8
		cd /tmp/_........./1/2/3/4/5/6/7/8
		.........
		pwd
		rm -rf /tmp/_.........
	)" '/tmp/_.........'
}; run-with-filter test--.........

function test--.......... {
	assert "$(
		rm -rf /tmp/_..........
		mkdir -p /tmp/_........../1/2/3/4/5/6/7/8/9
		cd /tmp/_........../1/2/3/4/5/6/7/8/9
		..........
		pwd
		rm -rf /tmp/_..........
	)" '/tmp/_..........'
}; run-with-filter test--..........

function test--cd---with-dir {
	assert "$(cd- ~/gh/dotfiles 2>&1; pwd)" "$HOME/gh/dotfiles"
}; run-with-filter test--cd---with-dir

function test--cd---with-file {
	assert "$(cd- ~/gh/dotfiles/zshrc-tests.zsh 2>&1; pwd)" "$HOME/gh/dotfiles"
}; run-with-filter test--cd---with-file

function test--cdl {
	assert "$(cdl; pwd)" "$HOME/Downloads"
}; run-with-filter test--cdl

function test--cdm {
	assert "$(cdm; pwd)" "$HOME/Documents"
}; run-with-filter test--cdm

function test--cdt {
	assert "$(cdt; pwd)" "$HOME/Desktop"
}; run-with-filter test--cdt

function test--tmp {
	assert "$(tmp; pwd)" '/tmp'
}; run-with-filter test--tmp

function test--cdd {
	assert "$(cdd; pwd)" "$HOME/gh/dotfiles"
}; run-with-filter test--cdd

function test--cde {
	# Skip: Not testing b/c function has other side effects
}

function test--cdg {
	assert "$(cdg; pwd)" "$HOME/gh"
}; run-with-filter test--cdg

function test--cdj {
	assert "$(cdj; pwd)" "$HOME/gh/jasonzhao6"
}; run-with-filter test--cdj

function test--cds {
	assert "$(cds; pwd)" "$HOME/gh/scratch"
}; run-with-filter test--cds

function test--cdtf {
	assert "$(cdtf; pwd)" "$HOME/gh/scratch/tf-debug"
}; run-with-filter test--cdtf
