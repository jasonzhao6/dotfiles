function git_helpers_merged {
	git branch --merged | egrep --invert-match '^\*.*$|^  main$|^  master$'
}
