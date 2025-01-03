function domain {
	git remote get-url origin | sed 's/.*[:/]\([^/]*\)\/.*\/.*/\1/'
}

function org {
	git remote get-url origin | sed 's/.*[:/]\([^/]*\)\/.*/\1/'
}

function repo {
	git rev-parse --show-toplevel | xargs basename
}

function branch {
	git rev-parse --abbrev-ref HEAD
}
