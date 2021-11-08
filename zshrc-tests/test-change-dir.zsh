function test_.. {
	local output=$(
		rm -rf /tmp/_..
		mkdir -p /tmp/_../1
		cd /tmp/_../1
		..
		pwd
	)

	rm -rf /tmp/_..

	local expected='/tmp/_..'

	[[ $output == $expected ]] && pass || fail 'test_..'
}; test_..

function test_... {
	local output=$(
		rm -rf /tmp/_...
		mkdir -p /tmp/_.../1/2
		cd /tmp/_.../1/2
		...
		pwd
	)

	rm -rf /tmp/_...

	local expected='/tmp/_...'

	[[ $output == $expected ]] && pass || fail 'test_...'
}; test_...

function test_.... {
	local output=$(
		rm -rf /tmp/_....
		mkdir -p /tmp/_..../1/2/3
		cd /tmp/_..../1/2/3
		....
		pwd
	)

	rm -rf /tmp/_....

	local expected='/tmp/_....'

	[[ $output == $expected ]] && pass || fail 'test_....'
}; test_....

function test_..... {
	local output=$(
		rm -rf /tmp/_.....
		mkdir -p /tmp/_...../1/2/3/4
		cd /tmp/_...../1/2/3/4
		.....
		pwd
	)

	rm -rf /tmp/_.....

	local expected='/tmp/_.....'

	[[ $output == $expected ]] && pass || fail 'test_.....'
}; test_.....

function test_...... {
	local output=$(
		rm -rf /tmp/_......
		mkdir -p /tmp/_....../1/2/3/4/5
		cd /tmp/_....../1/2/3/4/5
		......
		pwd
	)

	rm -rf /tmp/_......

	local expected='/tmp/_......'

	[[ $output == $expected ]] && pass || fail 'test_......'
}; test_......

function test_....... {
	local output=$(
		rm -rf /tmp/_.......
		mkdir -p /tmp/_......./1/2/3/4/5/6
		cd /tmp/_......./1/2/3/4/5/6
		.......
		pwd
	)

	rm -rf /tmp/_.......

	local expected='/tmp/_.......'

	[[ $output == $expected ]] && pass || fail 'test_.......'
}; test_.......

function test_........ {
	local output=$(
		rm -rf /tmp/_........
		mkdir -p /tmp/_......../1/2/3/4/5/6/7
		cd /tmp/_......../1/2/3/4/5/6/7
		........
		pwd
	)

	rm -rf /tmp/_........

	local expected='/tmp/_........'

	[[ $output == $expected ]] && pass || fail 'test_........'
}; test_........

function test_......... {
	local output=$(
		rm -rf /tmp/_.........
		mkdir -p /tmp/_........./1/2/3/4/5/6/7/8
		cd /tmp/_........./1/2/3/4/5/6/7/8
		.........
		pwd
	)

	rm -rf /tmp/_.........

	local expected='/tmp/_.........'

	[[ $output == $expected ]] && pass || fail 'test_.........'
}; test_.........

function test_.......... {
	local output=$(
		rm -rf /tmp/_..........
		mkdir -p /tmp/_........../1/2/3/4/5/6/7/8/9
		cd /tmp/_........../1/2/3/4/5/6/7/8/9
		..........
		pwd
	)

	rm -rf /tmp/_..........

	local expected='/tmp/_..........'

	[[ $output == $expected ]] && pass || fail 'test_..........'
}; test_..........

function test_cd_ {
	local output=$(
		cd_ ~/gh/dotfiles 2>&1
		pwd
	)

	local expected='gh/dotfiles'

	[[ $output == "$HOME/$expected" ]] && pass || fail 'test_cd_'
}; test_cd_

function test_cd- {
	local output=$(
		cd- ~/gh/dotfiles/zshrc-tests.zsh 2>&1
		pwd
	)

	local expected='gh/dotfiles'

	[[ $output == "$HOME/$expected" ]] && pass || fail 'test_cd-'
}; test_cd-

function test_cdl {
	local output=$(cdl; pwd)
	local expected="$HOME/Downloads"

	[[ $output == $expected ]] && pass || fail 'test_cdl'
}; test_cdl

function test_cdm {
	local output=$(cdm; pwd)
	local expected="$HOME/Documents"

	[[ $output == $expected ]] && pass || fail 'test_cdm'
}; test_cdm

function test_cdt {
	local output=$(cdt; pwd)
	local expected="$HOME/Desktop"

	[[ $output == $expected ]] && pass || fail 'test_cdt'
}; test_cdt

function test_tmp {
	local output=$(tmp; pwd)
	local expected='/tmp'

	[[ $output == $expected ]] && pass || fail 'test_tmp'
}; test_tmp

function test_cdd {
	# Not testing b/c has other side effects
}

function test_cde {
	# Not testing b/c has other side effects
}

function test_cdg {
	local output=$(cdg; pwd)
	local expected="$HOME/gh"

	[[ $output == $expected ]] && pass || fail 'test_cdg'
}; test_cdg

function test_cds {
	local output=$(cds; pwd)
	local expected="$HOME/gh/scratch"

	[[ $output == $expected ]] && pass || fail 'test_cds'
}; test_cds

function test_cdtf {
	local output=$(cdtf; pwd)
	local expected="$HOME/gh/scratch/tf-debug"

	[[ $output == $expected ]] && pass || fail 'test_cdtf'
}; test_cdtf
