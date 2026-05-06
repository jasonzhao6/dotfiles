# 2+ columns, consistent column count, minimum line count
function github_helpers_is_delimited {
	local delim=$1
	echo "$2" | awk -F"$delim" \
		-v min="$GITHUB_GIST_MIN_LINES" \
		'NR==1{n=NF} NF!=n || NF<2{exit 1} END{if(NR<min) exit 1}'
}
