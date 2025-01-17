# TODO rename to git_keymap.helpers.zsh

function git_merged {
	git branch --merged | egrep --invert-match '^\*.*$|^  main$|^  master$'
}
