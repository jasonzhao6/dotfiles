# 2+ columns, consistent column count, 3 minimum line to detect CSV/TSV
function github_helpers_is_delimited {
	local delim=$1
	echo "$2" | awk -F"$delim" \
		-v min=3 \
		'NR==1{n=NF} NF!=n || NF<2{exit 1} END{if(NR<min) exit 1}'
}
