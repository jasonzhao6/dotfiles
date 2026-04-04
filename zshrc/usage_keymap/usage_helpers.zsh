USAGE_SPARKLINE_CHARS=('▁' '▂' '▃' '▄' '▅' '▆' '▇')
USAGE_BAR_CHAR='█' # Missing bottom pixels in Terminal, so excluded from `USAGE_SPARKLINE_CHARS`
HORIZONTAL_BARS_MAX_WIDTH=30

function usage_helpers_horizontal_bars {
	# Reads lines of "label: count" from stdin
	# Renders horizontal bars up to HORIZONTAL_BARS_MAX_WIDTH
	local labels=()
	local counts=()
	local max_count=0
	local max_label_len=0
	local max_count_len=0

	# First pass: Collect data and track max widths for alignment
	local count_len
	while IFS=':' read -r label count; do
		count="${count# }" # Strip space after ':'
		labels+=("$label")
		counts+=("$count")
		[[ $count -gt $max_count ]] && max_count=$count
		[[ ${#label} -gt $max_label_len ]] && max_label_len=${#label}
		count_len=${#count}
		[[ $count_len -gt $max_count_len ]] && max_count_len=$count_len
	done

	# Second pass: Render each row with proportional bar
	local label count bar_len bar
	for (( idx = 1; idx <= ${#labels}; idx++ )); do
		label="${labels[$idx]}"
		count="${counts[$idx]}"
		bar_len=0
		[[ $max_count -gt 0 ]] && bar_len=$(( HORIZONTAL_BARS_MAX_WIDTH * count / max_count ))
		bar=''
		for (( i = 0; i < bar_len; i++ )); do
			bar+="$USAGE_BAR_CHAR"
		done
		printf "  %-*s  %*s  %s\n" "$max_label_len" "$label" "$max_count_len" "$count" "$(gray_fg "$bar")"
	done
}

function usage_helpers_sparklines {
	# Args: <sparkline_width> <group>
	#   group: "all" | "alias" | "namespace"
	# Stdin: raw usage data lines (timestamp\talias), pre-filtered by calendar_days
	# Stdout:
	#   group_key\tsparkline per group (one line each, colored)
	#   date_label on last line
	local sparkline_width=$1
	local group_by=$2

	# Read all data from stdin
	local lines=()
	while IFS= read -r line; do
		lines+=("$line")
	done

	# Compute date range from all timestamps
	# Data is expected to be sorted chronologically (oldest first)
	local first_ts="${${lines[1]}%%	*}"
	local first_date; strftime -s first_date '%Y-%m-%d' "$first_ts"
	local today; strftime -s today '%Y-%m-%d' "$EPOCHSECONDS"
	local first_epoch; first_epoch=$(gdate -d "$first_date" +%s)
	local today_epoch; today_epoch=$(gdate -d "$today" +%s)
	local total_days=$(( (today_epoch - first_epoch) / 86400 + 1 ))

	# Pick granularity based on width and total days
	local date_fmt label_fmt
	local num_weeks=$(( (total_days + 6) / 7 ))
	local num_months=$(( total_days / 30 + 1 ))
	local num_quarters=$(( total_days / 91 + 1 ))

	# Include year in labels if date range crosses a year boundary
	local first_year="${first_date%%-*}"
	local this_year="${today%%-*}"
	local cross_year=0
	[[ $first_year != "$this_year" ]] && cross_year=1

	# Pick finest granularity that fits the available width
	# Include year in labels when data crosses a year boundary
	if [[ $total_days -le $sparkline_width ]]; then
		date_fmt='%Y-%m-%d'
		[[ $cross_year -eq 1 ]] && label_fmt='%-m/%-d/%y' || label_fmt='%-m/%-d'
	elif [[ $num_weeks -le $sparkline_width ]]; then
		date_fmt='%Y-%W'
		[[ $cross_year -eq 1 ]] && label_fmt='%-m/%-d/%y' || label_fmt='%-m/%-d'
	elif [[ $num_months -le $sparkline_width ]]; then
		date_fmt='%Y-%m'
		[[ $cross_year -eq 1 ]] && label_fmt="%b '%y" || label_fmt='%b'
	elif [[ $num_quarters -le $sparkline_width ]]; then
		date_fmt='quarter'
		[[ $cross_year -eq 1 ]] && label_fmt="Q%q '%y" || label_fmt='Q%q'
	else
		date_fmt='%Y'; label_fmt='%Y'
	fi

	# Bucket by group and time, fill gaps for all granularities
	local bucket_result
	bucket_result=$(printf '%s\n' "${lines[@]}" | gawk -F'\t' \
		-v total_days="$total_days" -v date_fmt="$date_fmt" -v label_fmt="$label_fmt" \
		-v group="$group_by" '
	function get_quarter(ts) { return int((strftime("%m", ts) - 1) / 3) + 1 }
	function fmt_bucket(ts) {
		if (date_fmt == "quarter") return strftime("%Y", ts) "-Q" get_quarter(ts)
		return strftime(date_fmt, ts)
	}
	function fmt_label(ts) {
		if (date_fmt == "quarter") {
			q = get_quarter(ts)
			if (label_fmt ~ /%q/) {
				l = label_fmt
				gsub(/%q/, q, l)
				return strftime(l, ts)
			}
			return "Q" q
		}
		return strftime(label_fmt, ts)
	}
	{
		if (group == "all") group_key = "all"
		else if (group == "alias") group_key = $2
		else if (group == "namespace") group_key = substr($2, 1, 1)

		bucket = fmt_bucket($1)
		counts[group_key, bucket]++
		groups[group_key] = 1
	}
	END {
		# Build ordered bucket list with gap-filling
		now = systime()
		for (i = total_days - 1; i >= 0; i--) {
			t = now - i * 86400
			b = fmt_bucket(t)
			l = fmt_label(t)
			if (!(b in seen)) {
				seen[b] = 1
				order[++n] = b
				labels[n] = l
			}
		}

		# Output per-group sparkline data
		for (group_key in groups) {
			printf "%s", group_key
			for (i = 1; i <= n; i++) {
				printf "\t%d", counts[group_key, order[i]] + 0
			}
			printf "\n"
		}

		# Output date labels as last line
		printf "_labels\t%s\t%s\n", labels[1], labels[n]
	}')

	# First pass: collect all groups and find global max
	local -A group_counts
	local first_label last_label global_max=0
	local group_key rest
	while IFS=$'\t' read -r group_key rest; do
		if [[ $group_key == '_labels' ]]; then
			first_label="${rest%%	*}"
			last_label="${rest#*	}"
			continue
		fi
		group_counts[$group_key]="$rest"
		for count in ${(s:	:)rest}; do
			[[ $count -gt $global_max ]] && global_max=$count
		done
	done <<< "$bucket_result"

	# Second pass: render sparklines using global max
	local counts sparkline idx num_buckets=0
	for group_key in "${(@k)group_counts}"; do
		counts=("${(@s:	:)group_counts[$group_key]}")
		num_buckets=${#counts}

		sparkline=''
		for count in "${counts[@]}"; do
			if [[ $count -eq 0 ]]; then
				sparkline+='▁'
			else
				idx=$(( count * 6 / global_max ))
				[[ $idx -eq 0 ]] && idx=1
				[[ $idx -gt 6 ]] && idx=6
				sparkline+="${USAGE_SPARKLINE_CHARS[$((idx + 1))]}"
			fi
		done

		printf "%s\t%s\n" "$group_key" "$(gray_fg "$sparkline")"
	done

	# Derive granularity name from date_fmt
	local gran_name
	case "$date_fmt" in
		'%Y-%m-%d') gran_name='daily' ;;
		'%Y-%W')    gran_name='weekly' ;;
		'%Y-%m')    gran_name='monthly' ;;
		'quarter')  gran_name='quarterly' ;;
		'%Y')       gran_name='yearly' ;;
	esac

	# Last two lines: date range + granularity (prefixed with _labels/_gran for caller parsing)
	if [[ $first_label == "$last_label" ]]; then
		printf "_labels\t%s\n" "$first_label"
		printf "_gran\t(1 %s bucket)\n" "$gran_name"
	else
		local padding=$(( num_buckets - ${#first_label} - ${#last_label} ))
		[[ $padding -lt 2 ]] && padding=2
		printf "_labels\t%s%*s%s\n" "$first_label" "$padding" '' "$last_label"
		printf "_gran\t(%d %s buckets)\n" "$num_buckets" "$gran_name"
	fi
}

function usage_helpers_stats {
	# Prints two-line stats header from filtered usage data on stdin
	local filtered; filtered=$(cat)

	local file_size; file_size=$(ls -lh "$KEYMAP_USAGE_FILE" | awk '{s=$5; u=substr(s,length(s)); if(u=="B") s=substr(s,1,length(s)-1)" B"; else s=substr(s,1,length(s)-1)" "u"B"; print s}')

	# Compute all stats in one awk pass
	local stats
	stats=$(echo "$filtered" | gawk -F'\t' '
	{
		total++
		ns[substr($2,1,1)] = 1
		if (length($2) > 1) aliases[$2] = 1
		day = strftime("%Y-%m-%d", $1)
		day_counts[day]++
		day_ts[day] = $1
	}
	END {
		num_ns = 0; for (k in ns) num_ns++
		num_aliases = 0; for (k in aliases) num_aliases++
		num_days = asorti(day_counts, sorted)
		peak = 0
		for (i = 1; i <= num_days; i++) {
			if (day_counts[sorted[i]] > peak) {
				peak = day_counts[sorted[i]]
				peak_ts = day_ts[sorted[i]]
			}
		}
		first_ts = day_ts[sorted[1]]
		today_epoch = mktime(strftime("%Y %m %d 0 0 0"))
		first_epoch = mktime(strftime("%Y %m %d 0 0 0", first_ts))
		calendar_days = int((today_epoch - first_epoch) / 86400) + 1
		printf "%d\t%d\t%d\t%d\t%d\t%s", total, num_ns, num_aliases, calendar_days, peak, strftime("%-m/%-d/%y", peak_ts)
	}')
	local total; total=$(echo "$stats" | cut -f1)
	local unique_ns; unique_ns=$(echo "$stats" | cut -f2)
	local unique_keys; unique_keys=$(echo "$stats" | cut -f3)
	local num_days; num_days=$(echo "$stats" | cut -f4)
	local peak; peak=$(echo "$stats" | cut -f5)
	local peak_label; peak_label=$(echo "$stats" | cut -f6)
	local avg=$(( total / num_days ))

	# Align pipe separators between the two stats lines
	local col1a="Total: $(comma_num "$total")"
	local col1b="Namespaces: ${unique_ns}"
	local col2a="Avg: ${avg}/day"
	local col2b="Aliases: ${unique_keys}"
	local col3a="Peak: ${peak} (${peak_label})"
	local col3b="History: ${file_size}"

	local w1=$(( ${#col1a} > ${#col1b} ? ${#col1a} : ${#col1b} ))
	local w2=$(( ${#col2a} > ${#col2b} ? ${#col2a} : ${#col2b} ))

	printf "  %-*s  |  %-*s  |  %s\n" "$w1" "$col1a" "$w2" "$col2a" "$col3a"
	printf "  %-*s  |  %-*s  |  %s\n" "$w1" "$col1b" "$w2" "$col2b" "$col3b"
}

function usage_helpers_filter_by_calendar_days {
	# Filter usage data to last <n> calendar days. No arg means all data.
	local num_days=$1
	local max_ts; max_ts=$(gdate -d "tomorrow 00:00:00" +%s)
	local min_ts=0

	if [[ -n $num_days && $num_days -gt 0 ]]; then
		local start_date; start_date=$(gdate -d "-$(( num_days - 1 )) days" +%Y-%m-%d)
		min_ts=$(gdate -d "$start_date" +%s)
	fi

	awk -F'\t' -v min_ts="$min_ts" -v max_ts="$max_ts" '$1 >= min_ts && $1 < max_ts' "$KEYMAP_USAGE_FILE"
}


