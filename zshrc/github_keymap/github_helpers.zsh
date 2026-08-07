# 2+ columns, consistent column count, 3 minimum line to detect CSV/TSV
function github_helpers_is_delimited {
	local delim=$1
	echo "$2" | awk -F"$delim" \
		-v min=3 \
		'NR==1{n=NF} NF!=n || NF<2{exit 1} END{if(NR<min) exit 1}'
}

# Only a repo root counts, so subdirs don't shadow repo names or keymap searches
function github_helpers_is_repo_root {
	local target=$1
	[[ -n $target ]] || return

	[[ $(git -C "$target" rev-parse --show-toplevel 2> /dev/null) == ${target:A} ]]
}
