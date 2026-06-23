function git_helpers_merged {
	git branch --merged | grepE --invert-match '^\*.*$|^  main$|^  master$'
}
