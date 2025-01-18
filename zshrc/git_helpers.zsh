function git_merged {
	git branch --merged | egrep --invert-match '^\*.*$|^  main$|^  master$'
}
